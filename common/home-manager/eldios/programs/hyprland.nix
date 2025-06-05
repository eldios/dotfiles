{ pkgs, nixpkgs-unstable, config, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  # Preferred terminal emulator
  #terminal = "${pkgs.kitty}/bin/kitty";
  #terminal = "${pkgs.rio}/bin/rio";
  # Current terminal
  terminal = "${pkgs.ghostty}/bin/ghostty";

  rofi_opts = "-show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
  # Rofi menu for running commands
  quick_menu = "${pkgs.rofi}/bin/rofi -show run ${rofi_opts}";
  # Rofi menu for launching applications (drun)
  full_menu = "${pkgs.rofi}/bin/rofi -show drun ${rofi_opts}";
  # Rofi menu for browsing files
  file_menu = "${pkgs.rofi}/bin/rofi -show filebrowser ${rofi_opts}";

  # Power menu using wlogout
  powermenu = "${pkgs.wlogout}/bin/wlogout";
  # Screen locker command using swaylock-effects with a blur effect
  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000 --clock --effect-blur 7x5";
  # Command to launch Mailspring email client
  mail = "mailspring --password-store=\"gnome-libsecret\"";
  # Flameshot command for selecting an area to screenshot and copy to clipboard
  screenshot_select = "${pkgs.flameshot}/bin/flameshot gui -c";
  # Flameshot command for taking a full-screen screenshot (GUI mode)
  screenshot_full = "${pkgs.flameshot}/bin/flameshot gui";

  # Swayidle script for managing idle states: locks screen, then turns off display, then sleeps.
  swayidle = pkgs.writeShellScriptBin "swayidle-script" ''
    ${pkgs.swayidle}/bin/swayidle -w \
    timeout 300 '${lockscreen}' \ # Using the variable which has the full path
    timeout 360 '${pkgs.hyprland}/bin/hyprctl dispatch dpms off eDP-1 && ${pkgs.hyprland}/bin/hyprctl dispatch dpms off DP-1' \ # Turn off displays after 360 seconds
    resume '${pkgs.hyprland}/bin/hyprctl dispatch dpms on' \ # Resume displays on activity
    before-sleep '${lockscreen}' # Lock screen before system sleep
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
      wlr-layout-ui
      wlr-randr
      wlroots
      wlsunset
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
      # Commands to execute once on Hyprland startup
      exec-once = [
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP" # Ensures DBus environment is aware of Wayland specifics for systemd services
        "${pkgs.waybar}/bin/waybar" # Starts the Waybar status bar
        "${pkgs.mako}/bin/mako" # Starts the Mako notification daemon
        "${pkgs.variety}/bin/variety" # Starts Variety for wallpaper management
        # "${swayidle}/bin/swayidle-script" # Starts the swayidle daemon defined above
        # "${pkgs.eww}/bin/eww daemon && ${pkgs.eww}/bin/eww open eww_bar" # Start Eww daemon and open the bar
      ];

      # Monitor configuration (e.g., resolution, position, scale). Empty here means auto-config or configured elsewhere.
      monitor = [ ];

      general = {
        layout = "master"; # Default window layout (master-stack)
        resize_on_border = true; # Allows resizing windows by dragging borders
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        no_focus_fallback = true; # Prevents focus from falling back to desktop if no window is focusable
      };

      master = {
        # Settings for the master layout
        new_on_top = true; # New windows appear on top of the master stack
        mfact = 0.5; # Master area factor (percentage of screen width/height)
        orientation = "left"; # Master area position
        special_scale_factor = 0.8; # Scale factor for windows in special workspaces (e.g., scratchpad)
        allow_small_split = true; # Allows splitting even if the resulting window would be very small
        smart_resizing = true; # Enables smarter window resizing logic
      };

      decoration = {
        # Window decorations (blur, opacity, etc.)
        rounding = 10; # Corner rounding radius for windows
        blur = {
          # Blur settings for transparent windows
          enabled = true;
          size = 8; # Blur kernel size
          passes = 3; # Number of blur passes
          new_optimizations = true; # Use newer blur optimizations
          ignore_opacity = true; # Whether to blur windows with no transparency
          xray = true; # See through windows with blur
          contrast = 0.9;
          brightness = 0.8;
        };
        active_opacity = 0.95; # Opacity for active windows
        inactive_opacity = 0.85; # Opacity for inactive windows
      };

      animations = {
        # Animation settings for window transitions, workspaces, etc.
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05"; # Custom bezier curve for animations
        animation = [
          # Define various animations
          "windows, 1, 7, myBezier" # Window open/close animation
          "windowsOut, 1, 7, default, popin 80%" # Window close animation (pop out)
          "border, 1, 10, default" # Border animation
          "fade, 1, 7, default" # Fade animation for layers
          "workspaces, 1, 6, default" # Workspace switch animation
        ];
      };

      input = {
        # Input device settings (keyboard, mouse, touchpad)
        kb_layout = "us"; # Default keyboard layout
        follow_mouse = 1; # Focus follows mouse movement (1 = normal, 2 = aggressive)
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
        disable_hyprland_logo = true; # Disables the Hyprland logo on startup
        disable_splash_rendering = true; # Disables the startup splash screen
        mouse_move_enables_dpms = true; # Mouse movement wakes displays from DPMS
        key_press_enables_dpms = true; # Key press wakes displays from DPMS
        animate_manual_resizes = true; # Animate window resizes done manually
        animate_mouse_windowdragging = true; # Animate windows when dragged with mouse
        enable_swallow = true; # Enable window swallowing (e.g., terminal swallows child processes like image viewers)
      };

      "$mod" = "SUPER"; # Defines the Super (Windows/Command) key as the primary modifier

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

        # Eww bar toggle
        "$mod SHIFT CTRL, B, exec, ~/.config/eww/scripts/toggle-bar-mode.sh"

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
        "$mod SHIFT CTRL, R, exec, ${pkgs.hyprland}/bin/hyprctl reload"
      ];

      binde = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, sudo ${pkgs.light}/bin/light -A 5"
        ", XF86MonBrightnessDown, exec, sudo ${pkgs.light}/bin/light -U 5"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrule = [
        "float, title:^(pavucontrol)$"
        "float, title:^(nm-connection-editor)$"
        "float, title:^(org.gnome.Calculator)$"
        "float, title:^(org.gnome.Nautilus)$"
        "float, title:^(org.gnome.Settings)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(screenkey)$"
        "noborder, class:^(screenkey)$"
      ];

      workspace = [ ];
    };
  };
} # EOF
