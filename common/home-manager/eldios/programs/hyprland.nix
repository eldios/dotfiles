{
  pkgs,
  config,
  ...
}:
let
  terminal = "${pkgs.ghostty}/bin/ghostty";

  # Application launcher (rofi)
  quick_menu = "rofi-run";
  full_menu = "rofi-drun";
  file_menu = "rofi-filebrowser";
  window_menu = "rofi-window";

  # Bar selection: "waybar", "ironbar"
  # Change this to switch status bars
  barChoice = "waybar";
  barCmd =
    {
      waybar = "${pkgs.waybar}/bin/waybar";
      ironbar = "${pkgs.ironbar}/bin/ironbar";
    }
    .${barChoice};

  # Power menu using wlogout
  powermenu = "${pkgs.wlogout}/bin/wlogout";
  # Screen locker command using swaylock-effects with a blur effect
  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000 --clock --effect-blur 7x5";
  # Command to launch Mailspring email client
  mail = "mailspring --password-store=\"gnome-libsecret\"";
  # Screenshots using grimblast (Hyprland-native, grim+slurp wrapper)
  screenshot_select = "${pkgs.grimblast}/bin/grimblast copy area";
  screenshot_full = "${pkgs.grimblast}/bin/grimblast copysave screen ~/Pictures/Screenshots/$(date +%F_%T).png";
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
      cliphist
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
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP GDK_BACKEND NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT" # Enhanced DBus environment
        "${barCmd}" # Status bar (change barChoice in let block to switch)
        "${pkgs.mako}/bin/mako" # Starts the Mako notification daemon
        "${pkgs.swww}/bin/swww-daemon" # Wallpaper daemon (used by Variety's set_wallpaper script)
        "sleep 1 && ${pkgs.variety}/bin/variety" # Starts Variety for wallpaper management (after swww-daemon)
        # "${pkgs.eww}/bin/eww daemon && ${pkgs.eww}/bin/eww open eww_bar" # Start Eww daemon and open the bar
        "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store" # Clipboard history daemon (text + images)
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
        follow_mouse = 1; # Focus follows mouse movement (1 = normal, 2 = aggressive)
        kb_layout = "us"; # Default keyboard layout
        kb_options = "caps:escape"; # CapsLock -> Escape
        sensitivity = 0.5;
        touchpad = {
          natural_scroll = false;
          disable_while_typing = true;
          drag_lock = true;
        };
      };

      misc = {
        animate_manual_resizes = true; # Animate window resizes done manually
        animate_mouse_windowdragging = true; # Animate windows when dragged with mouse
        disable_hyprland_logo = true; # Disables the Hyprland logo on startup
        disable_splash_rendering = true; # Disables the startup splash screen
        enable_swallow = true; # Enable window swallowing (e.g., terminal swallows child processes like image viewers)
        key_press_enables_dpms = true; # Key press wakes displays from DPMS
        mouse_move_enables_dpms = true; # Mouse movement wakes displays from DPMS
        # swallow_regex = "^(ghostty|kitty)$"; # When opening a GUI app from terminal, terminal hides and reappears on close
        vfr = true; # enable Variable Frame rate
      };

      "$mod" = "SUPER"; # Defines the Super (Windows/Command) key as the primary modifier

      binds = {
        allow_workspace_cycles = true; # Allow workspace cycling with previous dispatcher
        workspace_back_and_forth = true; # Press same workspace key again to go back (i3-style)
      };

      bind = [
        # Window management
        "$mod SHIFT, C, killactive"

        "$mod, F, fullscreen"
        "$mod SHIFT, Space, togglefloating"

        # Dwindle layout controls
        "$mod, p, pseudo" # Toggle pseudo-tiling (fixed size windows)
        "$mod SHIFT, t, pin" # Pin floating window: stays visible across all workspaces (great for PiP/notes)

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

        # Previous workspace (quick jump back)
        "$mod, BackSpace, workspace, previous"

        # Urgent window focus (jump to window requesting attention)
        "$mod, z, focusurgentorlast"

        # Center floating window on screen
        "$mod, c, centerwindow"

        # Clipboard history (rofi picker, supports text + images)
        "$mod, v, exec, ${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy"

        # Window grouping (tabbed windows like i3)
        "$mod, g, togglegroup" # Create/dissolve a group from active window
        "$mod CTRL, Tab, changegroupactive, f" # Cycle forward through tabs in group
        "$mod CTRL SHIFT, Tab, changegroupactive, b" # Cycle backward through tabs in group
        "$mod SHIFT, g, lockactivegroup, toggle" # Lock group to prevent accidental changes
        "$mod CTRL, h, moveintogroup, l" # Move window into group on the left
        "$mod CTRL, j, moveintogroup, d" # Move window into group below
        "$mod CTRL, k, moveintogroup, u" # Move window into group above
        "$mod CTRL, l, moveintogroup, r" # Move window into group on the right
        "$mod CTRL SHIFT, h, moveoutofgroup" # Move window out of its group

        # Reload
        "$mod SHIFT, R, forcerendererreload"
        "$mod SHIFT CTRL, R, exec, ${pkgs.hyprland}/bin/hyprctl reload"
      ];

      # Global keybinds: passed to apps even when they're not focused (e.g. push-to-talk)
      # Uses dbus protocol, app must support org.freedesktop.portal.GlobalShortcuts
      # Example: bindglobal = [ "$mod, F5, pass, class:^(discord)$" ]; # passes key to Discord for push-to-talk

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
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
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
        "float, class:^(lxqt-openssh-askpass)$"
        "size 400 150, class:^(lxqt-openssh-askpass)$"
        "center, class:^(lxqt-openssh-askpass)$"
        "float, class:^(ssh-askpass)$"
        "size 400 150, class:^(ssh-askpass)$"
        "center, class:^(ssh-askpass)$"
        "float, title:^(OpenSSH)(.*)$"
        "size 400 150, title:^(OpenSSH)(.*)$"
        "center, title:^(OpenSSH)(.*)$"
        "float, title:^(pavucontrol)$"
        "float, title:^(nm-connection-editor)$"
        "float, title:^(org.gnome.Calculator)$"
        "float, title:^(org.gnome.Nautilus)$"
        "float, title:^(org.gnome.Settings)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(screenkey)$"
        "noborder, class:^(screenkey)$"
      ];

      layerrule = [
        "noanim, waybar"
        "noanim, ironbar"
      ];

      workspace = [ ];
    };
  };
} # EOF
