{ pkgs, ... }:

let
  rofi_common_opts = "-show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
  quick_menu = "${pkgs.rofi}/bin/rofi -show run ${rofi_common_opts}";
  full_menu = "${pkgs.rofi}/bin/rofi -show drun ${rofi_common_opts}";
  file_menu = "${pkgs.rofi}/bin/rofi -show filebrowser ${rofi_common_opts}";

  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000 --clock --effect-blur 7x5"; # Enhanced lockscreen command

  # Define swaymsg commands separately for clarity and robust parsing
  swaymsg_dpms_off = ''${pkgs.swayfx}/bin/swaymsg "output * dpms off"'';
  swaymsg_dpms_on = ''${pkgs.swayfx}/bin/swaymsg "output * dpms on"'';

  # FIXME: Verify sway package for swaymsg (pkgs.sway or pkgs.swayfx) - Using swayfx as per package config
  idle_and_lockscreen = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${lockscreen}' timeout 600 '${swaymsg_dpms_off}' resume '${swaymsg_dpms_on}' before-sleep '${lockscreen}'";

  daynightscreen = "${pkgs.wlsunset}/bin/wlsunset -l 43.841667 -L 10.502778";

  powermenu = "${pkgs.wlogout}/bin/wlogout";

in
{
  # BEGIN Sway confguration
  xdg.configFile."swaync/config.json" = {
    enable = true;
    executable = true;
    text = ''
      {
        "$schema": "/etc/xdg/swaync/configSchema.json",
        "positionX": "right",
        "positionY": "top",
        "layer": "overlay",
        "control-center-layer": "top",
        "layer-shell": true,
        "cssPriority": "application",
        "control-center-margin-top": 0,
        "control-center-margin-bottom": 0,
        "control-center-margin-right": 0,
        "control-center-margin-left": 0,
        "notification-2fa-action": true,
        "notification-inline-replies": false,
        "notification-icon-size": 64,
        "notification-body-image-height": 100,
        "notification-body-image-width": 200,
        "timeout": 10,
        "timeout-low": 5,
        "timeout-critical": 0,
        "fit-to-screen": true,
        "control-center-width": 500,
        "control-center-height": 600,
        "notification-window-width": 500,
        "keyboard-shortcuts": true,
        "image-visibility": "when-available",
        "transition-time": 200,
        "hide-on-clear": false,
        "hide-on-action": true,
        "script-fail-notify": true,
        "scripts": {},
        "notification-visibility": {},
        "widgets": [
          "inhibitors",
          "title",
          "dnd",
          "notifications"
        ],
        "widget-config": {
          "inhibitors": {
            "text": "Inhibitors",
            "button-text": "Clear All",
            "clear-all-button": true
          },
          "title": {
            "text": "Notifications",
            "clear-all-button": true,
            "button-text": "Clear All"
          },
          "dnd": {
            "text": "Do Not Disturb"
          },
          "label": {
            "max-lines": 5,
            "text": "Label Text"
          },
          "mpris": {
            "image-size": 96,
            "image-radius": 12
          }
        }
      }
    '';
  };

  home = {
    packages = with pkgs; [
      # BEGIN Sway confguration
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
      ghostty # Added as preferred terminal
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
      light # set brightness
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
      swaynotificationcenter
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
      xdg-desktop-portal-gtk
      xdg-utils # for opening default programs when clicking links
      ydotool
      # FIXME: Verify sway package for sway reload (pkgs.sway or pkgs.swayfx)
      (pkgs.writeShellScriptBin "fix-wm" ''
        ${pkgs.procps}/bin/pkill waybar && ${pkgs.swayfx}/bin/sway reload
      '') # EOF fix-wm script
    ];
  };

  wayland.windowManager.sway = {

    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;

    package = pkgs.swayfx;

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
      # Set TERMINAL env var if other tools need it, sway's 'terminal' setting is primary for sway keybindings
      # export TERMINAL="${pkgs.kitty}/bin/kitty";
      # export TERMINAL="${pkgs.rio}/bin/rio";
      # Current terminal
      export TERMINAL="${pkgs.ghostty}/bin/ghostty"
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
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

      # General settings from Hyprland / For a beautiful look
      gaps inner 5
      gaps outer 10
      default_border pixel 2
      focus_follows_mouse yes

      # Font configuration should be handled by Stylix.
      # Example: font pango:DejaVu Sans Mono 10 (if not fully covered by Stylix)

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

      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      # Set default terminal to ghostty
      terminal = "${pkgs.ghostty}/bin/ghostty";
      menu = "${pkgs.rofi}/bin/rofi"; # Assuming this is used with exec $menu

      startup = [
        { command = "${daynightscreen}"; }
        { command = "${pkgs.variety}/bin/variety"; }
        { command = "${idle_and_lockscreen}"; }
        # mako should be started by its systemd service (services.mako.enable = true)
        { command = "${pkgs.eww}/bin/eww daemon && ${pkgs.eww}/bin/eww open eww_bar"; } # Start eww widgets
      ];

      output = {
        "Virtual-1" = {
          res = "1920x1080";
          mode = "1920x1080@60Hz";
          pos = "0,0";
          transform = "0";
        };
        # "*" = { # change background for all outputs
        #   bg = "~/.dotfiles/users/alex/extraConfig/wallpapers/synthwave-night-skyscrapers.jpg fill";
        # };
      };

      workspaceLayout = "default";

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+m" = "exec mailspring --password-store='gnome-libsecret'";

        "${modifier}+d" = "exec ${full_menu}";
        "${modifier}+Shift+d" = "exec ${quick_menu}";
        "${modifier}+Shift+e" = "exec ${file_menu}"; # Added file menu

        "${modifier}+Shift+c" = "kill";
        "${modifier}+Ctrl+f" = "focus mode_toggle";
        "${modifier}+f" = "fullscreen toggle";

        "${modifier}+Ctrl+q" = "exec ${lockscreen}";

        "${modifier}+Shift+Ctrl+q" = "exec ${powermenu}";

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

        # FIXME: Verify package for pactl (e.g., pkgs.pulseaudio or pkgs.pipewire)
        "XF86AudioRaiseVolume" = "exec ${pkgs.pipewire}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pipewire}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pkgs.pipewire}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.pipewire}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86MonBrightnessDown" = "exec sudo ${pkgs.light}/bin/light -U 5%";
        "XF86MonBrightnessUp" = "exec sudo ${pkgs.light}/bin/light -A 5%";
        "Shift+XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify previous";
      }; # EOM keybindings

    }; # EOM config

  }; # EOM wayland WM sway

} # EOF
# vim: set ts=2 sw=2 et ai list nu
