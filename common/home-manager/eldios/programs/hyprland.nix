{ pkgs, ... }:
let
  terminal = "${pkgs.kitty}/bin/kitty";
  rofi_opts = "-show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
  quick_menu = "${pkgs.rofi}/bin/rofi -show run ${rofi_opts}";
  full_menu = "${pkgs.rofi}/bin/rofi -show drun ${rofi_opts}";
  file_menu = "${pkgs.rofi}/bin/rofi -show filebrowser ${rofi_opts}";

  powermenu = "${pkgs.wlogout}/bin/wlogout";
  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000 --clock --effect-blur 7x5";
  mail = "mailspring --password-store=\"gnome-libsecret\"";
  screenshot_select = "${pkgs.flameshot}/bin/flameshot gui -c";
  screenshot_full = "${pkgs.flameshot}/bin/flameshot gui";

  swayidle = pkgs.writeShellScriptBin "swayidle-script" ''
    swayidle -w \
    timeout 300 'swaylock' \
    timeout 360 'hyprctl dispatch dpms off eDP-1 && hyprctl dispatch dpms off DP-1' \
    resume 'hyprctl dispatch dpms on' \
    before-sleep 'swaylock'
  '';
in
{
  home = {
    packages = with pkgs; [
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      bemenu
      catppuccin-gtk
      catppuccin-kvantum
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
      nerdfonts
      papirus-icon-theme
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
        "hyprctl setcursor Catppuccin-Cursor 24"
        "waybar"
        "mako"
        "swayidle"
        "hyprpaper"
        "${pkgs.swaybg}/bin/swaybg -i ~/.config/wallpaper.jpg --mode fill"
      ];

      monitor = [ ];

      general = {
        layout = "master";
        resize_on_border = true;
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
        "col.inactive_border" = "rgba(1e1e2eff)";
        no_focus_fallback = true;
      };

      master = {
        new_on_top = true;
        mfact = 0.5;
        orientation = "left";
        special_scale_factor = 0.8;
        allow_small_split = true;
        smart_resizing = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          xray = true;
          contrast = 0.9;
          brightness = 0.8;
        };
        active_opacity = 0.95;
        inactive_opacity = 0.85;
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = false;
          disable_while_typing = true;
          drag_lock = true;
        };
        sensitivity = 0.5;
      };

      gestures = {
        workspace_swipe = true;
        workspace_swipe_forever = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        enable_swallow = true;
      };

      "$mod" = "SUPER";

      bind = [
        # Window management
        "$mod SHIFT, C, killactive"

        "$mod, F, fullscreen"
        #"$mod, Q, togglespecialworkspace"
        #"$mod SHIFT, Q, movetoworkspace, special"
        "$mod SHIFT, Space, togglefloating"

        # Master layout controls
        #"$mod, Return, layoutmsg, swapwithmaster"
        #"$mod, I, layoutmsg, addmaster"
        #"$mod, D, layoutmsg, removemaster"
        #"$mod, O, layoutmsg, orientationcycle left top right bottom"
        #"$mod SHIFT, O, layoutmsg, orientationcycle bottom left top right"
        #"$mod, P, pseudo"

        # Applications
        "$mod, D, exec, ${full_menu}"
        "$mod SHIFT, D, exec, ${quick_menu}"
        "$mod SHIFT, E, exec, ${file_menu}"
        "$mod, Return, exec, ${terminal}"
        "$mod SHIFT, M, exec, ${mail}"

        # System controls
        "$mod CTRL SHIFT, Q, exec, ${powermenu}"
        #"$mod CTRL SHIFT, Q, exit"
        "$mod CTRL, Q, exec, ${lockscreen}"

        # Screenshots
        "$mod SHIFT, S, exec, ${screenshot_select}"
        "$mod SHIFT, A, exec, ${screenshot_full}"

        # Focus
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # Move
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspacesilent, 1"
        "$mod SHIFT, 2, movetoworkspacesilent, 2"
        "$mod SHIFT, 3, movetoworkspacesilent, 3"
        "$mod SHIFT, 4, movetoworkspacesilent, 4"
        "$mod SHIFT, 5, movetoworkspacesilent, 5"
        "$mod SHIFT, 6, movetoworkspacesilent, 6"
        "$mod SHIFT, 7, movetoworkspacesilent, 7"
        "$mod SHIFT, 8, movetoworkspacesilent, 8"
        "$mod SHIFT, 9, movetoworkspacesilent, 9"
        "$mod SHIFT, 0, movetoworkspacesilent, 10"

        # Scratchpad
        "$mod SHIFT, minus, movetoworkspace, special:scratchpad"
        "$mod, minus, togglespecialworkspace, scratchpad"

        # Reload
        "$mod SHIFT, R, forcerendererreload"
        "$mod SHIFT CTRL, R, exec, hyprctl reload"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, sudo light -A 5"
        ", XF86MonBrightnessDown, exec, sudo light -U 5"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrule = [
        "float, ^(pavucontrol)$"
        "float, ^(nm-connection-editor)$"
        "float, ^(org.gnome.Calculator)$"
        "float, ^(org.gnome.Nautilus)$"
        "float, ^(org.gnome.Settings)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(screenkey)$"
        "noborder, class:^(screenkey)$"
      ];

      workspace = [ ];
    };
  };
} # EOF
