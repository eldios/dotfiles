{ pkgs, ... }:

let
  # Rofi application launcher
  quick_menu = "rofi-run";
  full_menu = "rofi-drun";
  file_menu = "rofi-filebrowser";
  window_menu = "rofi-window";

  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000 --clock --effect-blur 7x5";

  swaymsg_dpms_off = ''${pkgs.swayfx}/bin/swaymsg "output * dpms off"'';
  swaymsg_dpms_on = ''${pkgs.swayfx}/bin/swaymsg "output * dpms on"'';

  daynightscreen = "${pkgs.wlsunset}/bin/wlsunset -l 43.841667 -L 10.502778";

  powermenu = "${pkgs.wlogout}/bin/wlogout";

in
{
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
      ghostty
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
      mako # Wayland notification daemon
      pinentry-bemenu
      polkit_gnome
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      shotman
      slurp # screenshot functionality
      swaybg
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
      wshowkeys
      wtype
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-utils # for opening default programs when clicking links
      ydotool
      (pkgs.writeShellScriptBin "fix-wm" ''
        set -euo pipefail
        ${pkgs.procps}/bin/pkill waybar && ${pkgs.swayfx}/bin/sway reload
      '') # kills waybar and reloads sway config
    ];
  };

  wayland.windowManager.sway = {

    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    package = pkgs.swayfx-unwrapped;

    checkConfig = false;

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export NIXOS_OZONE_WL=1
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export GDK_BACKEND="wayland,x11"

      # Chromium/Electron apps Wayland support
      export ELECTRON_OZONE_PLATFORM_HINT=wayland
      export CHROME_EXECUTABLE="${pkgs.chromium}/bin/chromium"

      # Set TERMINAL env var if other tools need it, sway's 'terminal' setting is primary for sway keybindings
      export TERMINAL="${pkgs.ghostty}/bin/ghostty"
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT
    '';

    extraConfig = ''
      # Existing touchpad config
      input type:touchpad {
          left_handed disabled
          natural_scroll disabled
          tap enabled
          dwt enabled 
          accel_profile "flat" 
          pointer_accel 0.5 
      }

      # Existing flameshot rule (can be kept if flameshot is used alongside grimblast)
      for_window [app_id="flameshot"] floating enable, fullscreen disable, move absolute position 0 0, border pixel 0

      smart_borders smart
      smart_gaps smart
      default_border pixel 2
      default_floating_border pixel 2

      # Window rules from Hyprland
      for_window [title="^pavucontrol$"] floating enable
      for_window [app_id="^nm-connection-editor$"] floating enable
      for_window [app_id="^org.gnome.Calculator$"] floating enable
      for_window [app_id="^org.gnome.Nautilus$"] floating enable
      for_window [app_id="^org.gnome.Settings$"] floating enable
      for_window [title="^Picture-in-Picture$"] floating enable
      for_window [app_id="^screenkey$"] floating enable, border none
    ''; # EOM extraConfig

    config = rec {
      bars = [
        { command = "waybar"; }
      ];

      gaps = {
        inner = 2;
        outer = 0;
        top = 0; # No extra gap at top
        bottom = 0; # No extra gap at bottom
        left = 0; # No extra gap at left
        right = 0; # No extra gap at right
      };

      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      # Set default terminal to ghostty
      terminal = "${pkgs.ghostty}/bin/ghostty";
      menu = "rofi-drun";

      startup = [
        { command = "${pkgs.mako}/bin/mako"; }
        { command = "${daynightscreen}"; }
        { command = "${pkgs.variety}/bin/variety"; }
        #{ command = "${pkgs.eww}/bin/eww daemon && ${pkgs.eww}/bin/eww open eww_bar"; } # Start eww widgets
      ];

      output = {};

      workspaceLayout = "default";

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+m" = "exec mailspring --password-store='gnome-libsecret'";

        "${modifier}+d" = "exec ${full_menu}";
        "${modifier}+Shift+d" = "exec ${quick_menu}";
        "${modifier}+Shift+e" = "exec ${file_menu}"; # Added file menu
        "${modifier}+Shift+w" = "exec ${window_menu}"; # Added window menu

        "${modifier}+Shift+c" = "kill";
        "${modifier}+Ctrl+f" = "focus mode_toggle";
        "${modifier}+f" = "fullscreen toggle";

        "${modifier}+Ctrl+q" = "exec ${lockscreen}";

        "${modifier}+Shift+Ctrl+q" = "exec ${powermenu}";

        # Eww bar toggle
        "${modifier}+Shift+Ctrl+b" = "exec ~/.config/eww/scripts/toggle-bar-mode.sh";

        # Screenshots using grimblast
        "${modifier}+Shift+s" = "exec ${pkgs.grimblast}/bin/grimblast --notify copy area";
        "${modifier}+Shift+a" = "exec ${pkgs.grimblast}/bin/grimblast --notify copy screen";

        "${modifier}+Shift+Ctrl+r" = "reload";
        "${modifier}+Ctrl+r" = "mode resize";

        "${modifier}+Shift+Space" = "floating toggle";
        "${modifier}+u" = "focus parent";

        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+e" = "layout default";

        "${modifier}+v" = "layout toggle split";
        "${modifier}+Shift+v" = "splith";
        "${modifier}+Ctrl+v" = "splitv";

        "${modifier}+${left}" = "focus left";
        "${modifier}+${down}" = "focus down";
        "${modifier}+${up}" = "focus up";
        "${modifier}+${right}" = "focus right";

        "${modifier}+Shift+${left}" = "move left";
        "${modifier}+Shift+${down}" = "move down";
        "${modifier}+Shift+${up}" = "move up";
        "${modifier}+Shift+${right}" = "move right";

        "${modifier}+Ctrl+${left}" = "workspace prev";
        "${modifier}+Ctrl+${right}" = "workspace next";

        "${modifier}+minus" = "scratchpad show";
        "${modifier}+Shift+minus" = "move scratchpad";

        "${modifier}+Alt+${left}" = "move workspace to output left";
        "${modifier}+Alt+${down}" = "move workspace to output down";
        "${modifier}+Alt+${up}" = "move workspace to output up";
        "${modifier}+Alt+${right}" = "move workspace to output right";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
      }; # EOM keybindings

    }; # EOM config

  }; # EOM wayland WM sway

  # Add systemd user service for browser Wayland compatibility
  systemd.user.services.browser-wayland-env = {
    Unit = {
      Description = "Set browser Wayland environment variables";
      PartOf = [ "sway-session.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.systemd}/bin/systemctl --user import-environment NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT WAYLAND_DISPLAY'";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
