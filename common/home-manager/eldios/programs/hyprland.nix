{ pkgs, ...}:
let
  terminal = "${pkgs.kitty}/bin/kitty";

  quick_menu = "${pkgs.rofi}/bin/rofi -show run -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
  full_menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
  file_menu = "${pkgs.rofi}/bin/rofi -show filebrowser -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";

  powermenu = "${pkgs.wlogout}/bin/wlogout";
  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -c 000000";
  mail = "mailspring --password-store=\"gnome-libsecret\"";
  screenshot_select = "${pkgs.flameshot}/bin/flameshot gui -c";
  screenshot_full = "${pkgs.flameshot}/bin/flameshot gui";

  swayidle = pkgs.writeShellScriptBin "swayidle-script" ''
    swayidle -w \
    timeout 300 'swaylock' \
    timeout 360 'hyprctl dispatch dpms off eDP-1 && hyprctl dispatch dpms off DP-1' \
    resume '
     hyprctl monitors | grep HDMI
     ret=$?

     if [ $ret -eq 0 ]
     then
       hyprctl dispatch dpms on DP-1
     else
       hyprctl dispatch dpms on eDP-1
     fi
     ' \
    before-sleep 'swaylock' \
    lock 'swaylock'
  '';
in
{
  home = {
    packages = with pkgs; [
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      bemenu
      clipman
      dconf
      dracula-theme
      eww
      fuseiso
      fuzzel
      gammastep
      geoclue2
      glpaper
      gnome-themes-extra
      grim
      grimblast
      gsettings-desktop-schemas
      hyprland-protocols
      hyprpaper
      hyprpicker
      kitty
      lavalauncher
      libva-utils
      mako
      pinentry-bemenu
      polkit_gnome
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      rofi-wayland-unwrapped
      shotman
      slurp
      swaybg
      swayidle
      swaylock-effects
      swayr
      swayrbar
      swww
      tofi
      udiskie
      wayland
      wbg
      wdisplays
      wev
      wl-clipboard
      wl-gammactl
      wl-screenrec
      wlogout
      wlr-randr
      wlroots
      wlsunset
      wofi
      wshowkeys
      wtype
      xdg-desktop-portal
      xdg-desktop-portal-hyprland
      xdg-utils
      ydotool
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      exec-once = [
        "hyprctl setcursor Qogir 16"
        "waybar"
        "alacritty"
        "mako"
        "swayidle"
      ];

      monitor = [];

      general = {
        layout = "dwindle";
        resize_on_border = true;
        gaps_in = 5;
        gaps_out = 2;
        border_size = 0;
        no_focus_fallback = true;
      };

      misc = {
        layers_hog_keyboard_focus = false;
        disable_splash_rendering = true;
        force_default_wallpaper = 1;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = "yes";
          disable_while_typing = true;
          drag_lock = true;
        };
        sensitivity = 0.5;
        float_switch_override_focus = 2;
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
        #smart_split = true;
        #smart_resizing = true;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
      };

      windowrule = let
        f = regex: "float, ^(${regex})$";
      in [
        (f "org.gnome.Calculator")
        (f "org.gnome.Nautilus")
        (f "pavucontrol")
        (f "nm-connection-editor")
        (f "blueberry.py")
        (f "org.gnome.Settings")
        (f "org.gnome.design.Palette")
        (f "Color Picker")
        (f "xdg-desktop-portal")
        (f "xdg-desktop-portal-hyprland")
        "float, class:^(screenkey)$"
        "noborder, class:^(screenkey)$"
      ];

      binds.allow_workspace_cycles = true;

      decoration = {
        rounding = 0;
        dim_inactive = true;
        dim_strength = 0.05;

        blur = {
          enabled = true;
          size = 6;
          passes = 4;
          vibrancy = 0.4;
          new_optimizations = true;
          ignore_opacity = true;
          xray = true;
          special = true;
        };

        active_opacity = 1.0;
        inactive_opacity = 0.90;
      };

      animations = {
        enabled = true;
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "windowsMove, 1, 2, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      "$mod" = "SUPER";
      bind = [
        # Window management
        "$mod SHIFT     , C      , killactive"
        "$mod           , Q      , togglespecialworkspace"
        "$mod SHIFT     , Q      , movetoworkspace, special"
        "$mod           , F      , fullscreen"
        "$mod SHIFT     , Space  , togglefloating"

        # Layout controls
        "$mod           , e      , layoutmsg , togglesplit"
        "$mod           , w      , layoutmsg , toggletabbed"
        "$mod           , s      , layoutmsg , togglestack"
        "$mod           , v      , layoutmsg , preselect d"
        "$mod SHIFT     , v      , layoutmsg , preselect r"

        # Applications
        "$mod           , D      , exec      , ${full_menu}"
        "$mod SHIFT     , D      , exec      , ${quick_menu}"
        "$mod SHIFT     , E      , exec      , ${file_menu}"
        "$mod           , Return , exec      , ${terminal}"
        "$mod SHIFT     , m      , exec      , ${mail}"

        # System controls
        "$mod CTRL      , Q      , exec      , ${powermenu}"
        "$mod CTRL SHIFT, Q      , exit"
        "$mod CTRL      , L      , exec      , ${lockscreen}"

        # Screenshots
        "$mod SHIFT     , s      , exec      , ${screenshot_select}"
        "$mod SHIFT     , a      , exec      , ${screenshot_full}"

        # Focus
        "$mod           , h      , movefocus , l"
        "$mod           , j      , movefocus , d"
        "$mod           , k      , movefocus , u"
        "$mod           , l      , movefocus , r"

        # Move
        "$mod SHIFT     , h      , movewindow, l"
        "$mod SHIFT     , j      , movewindow, d"
        "$mod SHIFT     , k      , movewindow, u"
        "$mod SHIFT     , l      , movewindow, r"

        # Workspaces
        "$mod           , 1      , workspace , 1"
        "$mod           , 2      , workspace , 2"
        "$mod           , 3      , workspace , 3"
        "$mod           , 4      , workspace , 4"
        "$mod           , 5      , workspace , 5"
        "$mod           , 6      , workspace , 6"
        "$mod           , 7      , workspace , 7"
        "$mod           , 8      , workspace , 8"
        "$mod           , 9      , workspace , 9"
        "$mod           , 0      , workspace , 10"

        # Move to workspace
        "$mod SHIFT     , 1      , movetoworkspacesilent , 1"
        "$mod SHIFT     , 2      , movetoworkspacesilent , 2"
        "$mod SHIFT     , 3      , movetoworkspacesilent , 3"
        "$mod SHIFT     , 4      , movetoworkspacesilent , 4"
        "$mod SHIFT     , 5      , movetoworkspacesilent , 5"
        "$mod SHIFT     , 6      , movetoworkspacesilent , 6"
        "$mod SHIFT     , 7      , movetoworkspacesilent , 7"
        "$mod SHIFT     , 8      , movetoworkspacesilent , 8"
        "$mod SHIFT     , 9      , movetoworkspacesilent , 9"
        "$mod SHIFT     , 0      , movetoworkspacesilent , 10"

        # Scratchpad
        "$mod SHIFT     , minus  , movetoworkspace , special:scratchpad"
        "$mod           , minus  , togglespecialworkspace , scratchpad"

        # Reload/Restart
        "$mod SHIFT     , r      , forcerendererreload"
        "$mod SHIFT CTRL, r      , exec , hyprctl reload"

        # Media controls
        "               , XF86AudioNext   , exec , playerctl next"
        "               , XF86AudioPrev   , exec , playerctl previous"
        "               , XF86AudioPlay   , exec , playerctl play-pause"
        "               , XF86AudioPause  , exec , playerctl pause"
        "               , XF86AudioStop   , exec , playerctl stop"
      ];

      binde = [
        "               , XF86AudioRaiseVolume  , exec , wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        "               , XF86AudioLowerVolume  , exec , wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "               , XF86MonBrightnessUp   , exec , light -A 5"
        "               , XF86MonBrightnessDown , exec , light -U 5"
      ];

      bindm = [
        "$mod           , mouse:272 , movewindow"
        "$mod           , mouse:273 , resizewindow"
      ];

      xwayland.force_zero_scaling = true;
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
