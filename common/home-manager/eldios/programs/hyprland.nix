{
  pkgs,
  config,
  ...
}:
let
  # Preferred terminal emulator
  #terminal = "${pkgs.kitty}/bin/kitty";
  #terminal = "${pkgs.rio}/bin/rio";
  # Current terminal
  terminal = "${pkgs.ghostty}/bin/ghostty";

  # Use the unified rofi scripts from rofi.nix
  # Rofi menu for running commands
  quick_menu = "rofi-run";
  # Rofi menu for launching applications (drun)
  full_menu = "rofi-drun";
  # Rofi menu for browsing files
  file_menu = "rofi-filebrowser";
  # Rofi menu for window selection
  window_menu = "rofi-window";

  # Power menu using wlogout
  powermenu = "${pkgs.wlogout}/bin/wlogout";
  # Screen locker command using swaylock-effects with a blur effect
  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000 --clock --effect-blur 7x5";
  # Command to launch Mailspring email client
  mail = "mailspring --password-store=\"gnome-libsecret\"";
  # Flameshot command for selecting an area to screenshot and copy to clipboard
  screenshot_select = "flameshot gui -c";
  # Flameshot command for taking a full-screen screenshot (GUI mode)
  screenshot_full = "flameshot gui";
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
      hyprshot
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
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT" # Enhanced DBus environment
        "${pkgs.waybar}/bin/waybar" # Starts the Waybar status bar
        "${pkgs.mako}/bin/mako" # Starts the Mako notification daemon
        "${pkgs.variety}/bin/variety" # Starts Variety for wallpaper management
        # "${pkgs.eww}/bin/eww daemon && ${pkgs.eww}/bin/eww open eww_bar" # Start Eww daemon and open the bar
      ];

      # Environment variables for Wayland compatibility
      env = [
        "NIXOS_OZONE_WL,1"
        "MOZ_ENABLE_WAYLAND,1"
        "QT_QPA_PLATFORM,wayland"
        "GDK_BACKEND,wayland,x11"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "WAYLAND_DISPLAY,wayland-1"
      ];

      # Monitor configuration - sets up dual monitor layout
      monitor = [ ];

      general = {
        layout = "dwindle"; # Use dwindle layout (binary tree) instead of master-stack
        resize_on_border = true; # Allows resizing windows by dragging borders
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        no_focus_fallback = true; # Prevents focus from falling back to desktop if no window is focusable
      };

      # Settings for the dwindle layout
      dwindle = {
        pseudotile = false; # Enable pseudotiling on dwindle
        preserve_split = true; # Preserves split direction when opening new windows
        #no_gaps_when_only = false; # Keep gaps when there's only one window
        force_split = 0; # 0 = split follows mouse, 1 = always split to the left/top, 2 = always to the right/bottom
        use_active_for_splits = true; # Use the active window as the split target
        default_split_ratio = 1.0; # Default split ratio (0.1 - 1.9)
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

        # Custom bezier curve for fade animations
        bezier = [
          "fadeBezier, 0.1, 0.9, 0.1, 1" # Elegant fade effect
        ];

        # Detailed animation configurations, all set to use fade
        animation = [
          # Windows - fade only
          "windows, 1, 6, fadeBezier"
          "windowsOut, 1, 6, fadeBezier"
          "windowsMove, 1, 5, fadeBezier"

          # Fading effects
          "fade, 1, 8, fadeBezier"
          "fadeOut, 1, 5, fadeBezier"
          "fadeIn, 1, 5, fadeBezier"
          "fadeDim, 1, 4, fadeBezier"

          # Borders
          "border, 1, 10, fadeBezier"

          # Workspace transitions - fade only
          "workspaces, 1, 7, fadeBezier"
          "specialWorkspace, 1, 6, fadeBezier"

          # Layers
          "layers, 1, 8, fadeBezier"
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
        "$mod SHIFT, Space, togglefloating"

        # Dwindle layout controls
        "$mod, p, pseudo" # Toggle pseudo-tiling (fixed size windows)
        "$mod SHIFT, t, pin" # Toggle pseudo-tiling (fixed size windows)

        "$mod, i, cyclenext" # Cycle window focus
        "$mod, o, cyclenext, prev" # Cycle window focus
        "$mod SHIFT, i, swapnext" # Swap with window in direction
        "$mod SHIFT, o, swapnext, prev" # Swap with window in direction

        "$mod, x, togglesplit" # Toggle split direction
        "$mod SHIFT, x, layoutmsg, togglesplit" # Toggle between dwindle/master

        # Applications
        "$mod, D, exec, ${full_menu}"
        "$mod SHIFT, D, exec, ${quick_menu}"
        "$mod SHIFT, E, exec, ${file_menu}"
        "$mod SHIFT, W, exec, ${window_menu}"
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
        "$mod, Tab, focusmonitor, +1"
        "$mod SHIFT, Tab, focusmonitor, -1"

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
        "$mod, minus, togglespecialworkspace, scratchpad"
        "$mod SHIFT, minus, movetoworkspace, special:scratchpad"

        # Reload
        "$mod SHIFT, R, forcerendererreload"
        "$mod SHIFT CTRL, R, exec, ${pkgs.hyprland}/bin/hyprctl reload"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Add resize bindings with keyboard
      binde = [
        # Volume and media controls
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, sudo ${pkgs.light}/bin/light -A 5"
        ", XF86MonBrightnessDown, exec, sudo ${pkgs.light}/bin/light -U 5"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"

        # Window resize bindings (for dwindle layout)
        "$mod ALT, h, resizeactive, -20 0"
        "$mod ALT, l, resizeactive, 20 0"
        "$mod ALT, k, resizeactive, 0 -20"
        "$mod ALT, j, resizeactive, 0 20"
        "$mod SHIFT ALT, h, resizeactive, -100 0"
        "$mod SHIFT ALT, l, resizeactive, 100 0"
        "$mod SHIFT ALT, k, resizeactive, 0 -100"
        "$mod SHIFT ALT, j, resizeactive, 0 100"
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
