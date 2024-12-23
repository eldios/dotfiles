{ pkgs, ...}:
let
  terminal = "${pkgs.kitty}/bin/kitty";

  quick_menu = "${pkgs.rofi}/bin/rofi -show run -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
  full_menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
  file_menu = "${pkgs.rofi}/bin/rofi -show filebrowser -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";

  powermenu = "${pkgs.wlogout}/bin/wlogout";

  mail = "mailspring --password-store=\"gnome-libsecret\"";

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
  # BEGIN Hyprlan confguration
  home = {
    packages = with pkgs; [
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      bemenu # wayland clone of dmenu
      clipman
      dconf
      dracula-theme # gtk theme
      eww
      fuseiso
      fuzzel # wayland clone of dmenu
      gammastep
      geoclue2
      glpaper
      gnome-themes-extra
      grim # screenshot functionality
      grimblast # screenshot functionality
      gsettings-desktop-schemas
      hyprland-protocols
      hyprpaper
      hyprpicker
      kitty
      lavalauncher # simple launcher panel for Wayland desktops
      libva-utils
      mako # notification system developed by swaywm maintainer
      pinentry-bemenu
      polkit_gnome
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      rofi-wayland-unwrapped
      shotman
      slurp # screenshot functionality
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
      wdisplays # tool to configure displays
      wev
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
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
      xdg-utils # for opening default programs when clicking links
      ydotool
    ];
  };

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;

    settings = {
      exec-once = [
        #"systemctl --user restart swaybg xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk"
        "hyprctl setcursor Qogir 16"
        "waybar"
        "alacritty"
        "mako"
        "swayidle"
      ];

      monitor = [
        #"eDP-1, 1920x1080, 0x0, 1"
        # "HDMI-A-1, 2560x1440, 1920x0, 1"
        # ",preferred,auto,1"
      ];

      general = {
        layout = "dwindle";
        resize_on_border = true;
        gaps_in = 3;
        gaps_out = 3;
        border_size = 2;
      };

      misc = {
        layers_hog_keyboard_focus = false;
        disable_splash_rendering = true;
        force_default_wallpaper = 1;
      };

      input = {
        kb_layout = "us"; #"it"
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
      ];

      binds = {
        allow_workspace_cycles = true;
      };

      decoration = {
        # See https://wiki.hyprland.org/Configuring/Variables/ for more

        rounding = 1;

        dim_inactive = false;
        dim_strength = 0.7;

        blur = {
          enabled = true;
          size = 6;
          passes = 4;
          # contrast = 0.8916;
          # brightness = 0.8172;
          vibrancy = 0.4;
          new_optimizations = true;
          ignore_opacity = true;
          xray = true;
          special = true;
        };
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
        "$mod SHIFT     , C, killactive ,"

        "$mod           , Q, togglespecialworkspace"
        "$mod SHIFT     , Q, movetoworkspace, special"

        "$mod           , D , exec , ${full_menu}"
        "$mod SHIFT     , D , exec , ${quick_menu}"
        "$mod SHIFT     , E , exec , ${file_menu}"

        "$mod           , F , fullscreen , 0"
        "$mod SHIFT     , Space , togglefloating ,"

        "$mod           , R , togglegroup ,"
        "$mod SHIFT     , J , changegroupactive, f"
        "$mod SHIFT     , K , changegroupactive, b"

        "$mod SHIFT     , m , exec, ${mail}"

        "$mod           , Return , exec , ${terminal}"

        "$mod CTRL      , Q , exec , ${powermenu}"
        "$mod CRLT SHIFT, Q , exit ,"

        # "$mod , E  , exec , emacsclient -c -a 'nvim'"
        # "ALT   , E , exec , emacsclient -c -eval '(dired nil)'"

        "               , print, exec , wl-ocr"
        "CTRL           , print, exec , grimblast save area - | swappy -f -"
        "ALT            , print, exec , grimblast --notify --cursor copysave output ~/Pictures/Screenshots/$(date +'%s.png')"

        # Dwindle Keybind
        "$mod           , h , movefocus , l"
        "$mod           , j , movefocus , d"
        "$mod           , k , movefocus , u"
        "$mod           , l , movefocus , r"

        "$mod SHIFT     , h , movewindow , l"
        "$mod SHIFT     , j , movewindow , d"
        "$mod SHIFT     , k , movewindow , u"
        "$mod SHIFT     , l , movewindow , r"

        "$mod           , 1 , workspace , 1"
        "$mod           , 2 , workspace , 2"
        "$mod           , 3 , workspace , 3"
        "$mod           , 4 , workspace , 4"
        "$mod           , 5 , workspace , 5"
        "$mod           , 6 , workspace , 6"
        "$mod           , 7 , workspace , 7"
        "$mod           , 8 , workspace , 8"
        "$mod           , 9 , workspace , 9"
        "$mod           , 0 , workspace , 10"

        "$mod SHIFT     , 1 , movetoworkspacesilent , 1"
        "$mod SHIFT     , 2 , movetoworkspacesilent , 2"
        "$mod SHIFT     , 3 , movetoworkspacesilent , 3"
        "$mod SHIFT     , 4 , movetoworkspacesilent , 4"
        "$mod SHIFT     , 5 , movetoworkspacesilent , 5"
        "$mod SHIFT     , 6 , movetoworkspacesilent , 6"
        "$mod SHIFT     , 7 , movetoworkspacesilent , 7"
        "$mod SHIFT     , 8 , movetoworkspacesilent , 8"
        "$mod SHIFT     , 9 , movetoworkspacesilent , 9"
        "$mod SHIFT     , 0 , movetoworkspacesilent , 10"

        "               , XF86AudioNext  , exec , ${pkgs.playerctl}/bin/playerctl next"
        "               , XF86AudioPrev  , exec , ${pkgs.playerctl}/bin/playerctl previous"
        "               , XF86AudioPlay  , exec , ${pkgs.playerctl}/bin/playerctl play-pause"
        "               , XF86AudioPause , exec , ${pkgs.playerctl}/bin/playerctl pause"
        "               , XF86AudioStop  , exec , ${pkgs.playerctl}/bin/playerctl stop"
      ];

      binde = [
        "               , XF86AudioRaiseVolume  , exec , ${pkgs.alsa-utils}/bin/amixer -q set Master 5%+"
        "               , XF86AudioLowerVolume  , exec , ${pkgs.alsa-utils}/bin/amixer -q set Master 5%-"

        "               , XF86MonBrightnessUp   , exec , ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"
        "               , XF86MonBrightnessDown , exec , ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
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
