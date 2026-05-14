{
  lib,
  pkgs,
  config,
  ...
}: let
  terminal = "${pkgs.ghostty}/bin/ghostty";
  colors = config.lib.stylix.colors;
  activeBorder = "rgba(${colors.base0D}aa)";
  inactiveBorder = "rgba(${colors.base03}aa)";

  # Application launchers use Walker, matching the Omarchy runtime menu stack.
  quick_menu = "/etc/profiles/per-user/eldios/bin/omarchy-launch-run";
  full_menu = "/etc/profiles/per-user/eldios/bin/omarchy-launch-apps";
  file_menu = "/etc/profiles/per-user/eldios/bin/omarchy-launch-files";
  window_menu = "/etc/profiles/per-user/eldios/bin/omarchy-launch-windows";
  omarchyMenu = "/etc/profiles/per-user/eldios/bin/omarchy-menu";

  # Bar selection: "waybar", "ironbar"
  # Change this to switch status bars
  barChoice = "waybar";
  barCmd =
    {
      waybar = "${pkgs.waybar}/bin/waybar";
      ironbar = "${pkgs.ironbar}/bin/ironbar";
    }
    .${
      barChoice
    };

  # Power menu using wlogout
  powermenu = "${pkgs.wlogout}/bin/wlogout";
  # Command to launch Mailspring email client
  mail = "mailspring --password-store=\"gnome-libsecret\"";
  # Screenshots using grimblast (Hyprland-native, grim+slurp wrapper)
  screenshot_select = "${pkgs.grimblast}/bin/grimblast copy area";
  screenshot_full = "${pkgs.grimblast}/bin/grimblast copysave screen ~/Pictures/Screenshots/$(date +%F_%T).png";
in {
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
      wl-clip-persist
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
      # xdg-desktop-portal-hyprland provided system-wide via
      # programs.hyprland.portalPackage (nixpkgs-unstable); adding it here
      # would pull a second copy and conflict on hyprland-share-picker.
      xdg-utils
      ydotool
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    # Match common/nixos/programs/hyprland.nix (nixpkgs-unstable, ~v0.54.3+)
    # so HM-injected config targets the same Hyprland version the session runs.
    package = pkgs.unstable.hyprland;
    xwayland.enable = true;
    systemd.enable = true;
    extraConfig = ''
      source = ${config.home.homeDirectory}/.config/hypr/omarchy-theme.conf

      # Window rules in block syntax (Hyprland 0.54.3+ removed the legacy
      # `windowrule = float, class:...` form). Each block requires a unique
      # `name` as the first directive and one property per line.

      # Omarchy presentation terminal (interactive installs/updates).
      windowrule {
        name = float-omarchy-terminal
        match:class = ^(org\.omarchy\.terminal)$
        float = yes
        size = 1120 720
        center = 1
      }

      windowrule {
        name = float-ssh-askpass
        match:class = ^(lxqt-openssh-askpass|ssh-askpass)$
        float = yes
        size = 400 150
        center = 1
      }

      windowrule {
        name = float-openssh-title
        match:title = ^(OpenSSH)(.*)$
        float = yes
        size = 400 150
        center = 1
      }

      windowrule {
        name = float-pavucontrol
        match:title = ^(pavucontrol)$
        float = yes
      }
      windowrule {
        name = float-nm-connection-editor
        match:title = ^(nm-connection-editor)$
        float = yes
      }
      windowrule {
        name = float-gnome-calculator
        match:title = ^(org\.gnome\.Calculator)$
        float = yes
      }
      windowrule {
        name = float-gnome-nautilus
        match:title = ^(org\.gnome\.Nautilus)$
        float = yes
      }
      windowrule {
        name = float-gnome-settings
        match:title = ^(org\.gnome\.Settings)$
        float = yes
      }
      windowrule {
        name = float-pip
        match:title = ^(Picture-in-Picture)$
        float = yes
        pin = yes
      }
      windowrule {
        name = float-screenkey
        match:class = ^(screenkey)$
        float = yes
        border_size = 0
      }
      windowrule {
        name = float-blueman
        match:class = ^(blueman-manager)$
        float = yes
      }
      windowrule {
        name = float-thunar
        match:class = ^(thunar)$
        float = yes
      }
      windowrule {
        name = float-pcmanfm
        match:class = ^(pcmanfm)$
        float = yes
      }
      windowrule {
        name = float-file-roller
        match:class = ^(org\.gnome\.FileRoller)$
        float = yes
      }
      windowrule {
        name = float-portal-gtk
        match:class = ^(xdg-desktop-portal-gtk)$
        float = yes
      }

      # Strip every decoration effect from fullscreen windows. Re-evaluates on
      # every fullscreen state change.
      windowrule {
        name = fullscreen-no-effects
        match:fullscreen = 1
        no_blur = 1
        no_dim = 1
        no_shadow = 1
        rounding = 0
        opaque = 1
      }
    '';

    settings = {
      # Suppress the on-screen red error overlay for non-fatal config errors
      # (e.g. missing `source` targets like omarchy themes without hyprlock.conf).
      debug.suppress_errors = true;

      # Commands to execute once on Hyprland startup
      exec-once = [
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP GDK_BACKEND NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT" # Enhanced DBus environment
        "${barCmd}" # Status bar (change barChoice in let block to switch)
        "${pkgs.mako}/bin/mako" # Starts the Mako notification daemon
        "${pkgs.swww}/bin/swww-daemon" # Wallpaper daemon (used by Variety's set_wallpaper script)
        "sleep 1 && ${pkgs.swww}/bin/swww img ~/.config/omarchy/current/background --transition-type fade"
        # "${pkgs.eww}/bin/eww daemon && ${pkgs.eww}/bin/eww open eww_bar" # Start Eww daemon and open the bar
        "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard regular" # Keep clipboard contents after source apps exit
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
      monitor = [];

      general = {
        layout = "dwindle"; # Use dwindle layout (binary tree) instead of master-stack
        resize_on_border = true; # Allows resizing windows by dragging borders
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = lib.mkDefault activeBorder;
        "col.inactive_border" = lib.mkDefault inactiveBorder;
        allow_tearing = false;
        no_focus_fallback = true; # Prevents focus from falling back to desktop if no window is focusable
      };

      # Settings for the dwindle layout
      dwindle = {
        pseudotile = true; # Enable pseudotiling on dwindle
        preserve_split = true; # Preserves split direction when opening new windows
        #no_gaps_when_only = false; # Keep gaps when there's only one window
        force_split = 2; # Open new splits predictably on the right/bottom
        use_active_for_splits = true; # Use the active window as the split target
        default_split_ratio = 1.0; # Default split ratio (0.1 - 1.9)
      };

      group = {
        "col.border_active" = lib.mkDefault activeBorder;
        "col.border_inactive" = lib.mkDefault inactiveBorder;
        "col.border_locked_active" = lib.mkDefault "-1";
        "col.border_locked_inactive" = lib.mkDefault "-1";

        groupbar = {
          font_size = lib.mkDefault 12;
          font_family = lib.mkDefault config.stylix.fonts.monospace.name;
          font_weight_active = lib.mkDefault "ultraheavy";
          font_weight_inactive = lib.mkDefault "normal";
          indicator_height = lib.mkDefault 0;
          indicator_gap = lib.mkDefault 5;
          height = lib.mkDefault 22;
          gaps_in = lib.mkDefault 5;
          gaps_out = lib.mkDefault 0;
          text_color = lib.mkDefault "rgb(${colors.base05})";
          text_color_inactive = lib.mkDefault "rgba(${colors.base04}cc)";
          "col.active" = lib.mkDefault "rgba(${colors.base02}aa)";
          "col.inactive" = lib.mkDefault "rgba(${colors.base01}88)";
          gradients = lib.mkDefault true;
          gradient_rounding = lib.mkDefault 0;
          gradient_round_only_edges = lib.mkDefault false;
        };
      };

      decoration = {
        # Window decorations (blur, opacity, etc.)
        rounding = 10; # Corner rounding radius for windows
        shadow = {
          enabled = lib.mkDefault true;
          range = lib.mkDefault 4;
          render_power = lib.mkDefault 3;
          color = lib.mkDefault "rgba(00000066)";
        };
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

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "windowsMove, 1, 5, easeOutQuint"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "fadeDim, 1, 4, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 5, easeOutQuint"
          "specialWorkspace, 1, 4, easeOutQuint, slidevert"
        ];
      };

      input = {
        # Input device settings (keyboard, mouse, touchpad)
        follow_mouse = 1; # Focus follows mouse movement (1 = normal, 2 = aggressive)
        kb_layout = "us"; # Default keyboard layout
        kb_options = "caps:escape"; # CapsLock -> Escape
        repeat_rate = 40;
        repeat_delay = 250;
        numlock_by_default = true;
        sensitivity = 0.5;
        touchpad = {
          natural_scroll = false;
          disable_while_typing = true;
          drag_lock = true;
          scroll_factor = 0.4;
          clickfinger_behavior = true;
        };
      };

      misc = {
        animate_manual_resizes = true; # Animate window resizes done manually
        animate_mouse_windowdragging = true; # Animate windows when dragged with mouse
        disable_hyprland_logo = true; # Disables the Hyprland logo on startup
        disable_splash_rendering = true; # Disables the startup splash screen
        disable_scale_notification = true;
        enable_swallow = true; # Enable window swallowing (e.g., terminal swallows child processes like image viewers)
        focus_on_activate = true;
        key_press_enables_dpms = true; # Key press wakes displays from DPMS
        mouse_move_enables_dpms = true; # Mouse movement wakes displays from DPMS
        allow_session_lock_restore = true;
        anr_missed_pings = 3;
        # swallow_regex = "^(ghostty|kitty)$"; # When opening a GUI app from terminal, terminal hides and reappears on close
        vfr = true; # enable Variable Frame rate
      };

      cursor = {
        hide_on_key_press = true;
        warp_on_change_workspace = 1;
      };

      "$mod" = "SUPER"; # Defines the Super (Windows/Command) key as the primary modifier

      binds = {
        allow_workspace_cycles = true; # Allow workspace cycling with previous dispatcher
        workspace_back_and_forth = true; # Press same workspace key again to go back (i3-style)
        hide_special_on_workspace_change = true;
      };

      bind = [
        # Window management
        "$mod SHIFT, C, killactive"

        "$mod, F, fullscreen"
        "$mod SHIFT, Space, togglefloating"

        # Toggle no_dim + no_blur on the active window (persists for window
        # lifetime). State tracked per-window-address in XDG_RUNTIME_DIR.
        "$mod ALT, B, exec, omarchy-window-undim-blur-toggle"

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
        "$mod, Space, exec, ${full_menu}"
        "$mod ALT, Space, exec, ${omarchyMenu}"
        "$mod CTRL, E, exec, /etc/profiles/per-user/eldios/bin/omarchy-launch-walker -m symbols"
        "$mod SHIFT, M, exec, ${mail}"

        # System controls
        "$mod CTRL SHIFT, Q, exec, ${powermenu}"
        #"$mod CTRL SHIFT, Q, exit"
        # Lock binding ($mod CTRL, Q) lives in ./hyprlock.nix (opt-in).
        "$mod, Escape, exec, ${powermenu}"

        # Eww bar toggle
        "$mod SHIFT CTRL, B, exec, ~/.config/eww/scripts/toggle-bar-mode.sh"

        # Screenshots
        "$mod SHIFT, S, exec, ${screenshot_select}"
        "$mod SHIFT, A, exec, ${screenshot_full}"
        "$mod, Print, exec, ${pkgs.procps}/bin/pkill hyprpicker || ${pkgs.hyprpicker}/bin/hyprpicker -a"

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

        # Clipboard history
        "$mod, v, exec, /etc/profiles/per-user/eldios/bin/omarchy-launch-walker -m clipboard"

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
        "$mod ALT, Tab, changegroupactive, f"
        "$mod ALT SHIFT, Tab, changegroupactive, b"
        "$mod ALT, 1, changegroupactive, 1"
        "$mod ALT, 2, changegroupactive, 2"
        "$mod ALT, 3, changegroupactive, 3"
        "$mod ALT, 4, changegroupactive, 4"
        "$mod ALT, 5, changegroupactive, 5"

        # Omarchy-inspired monitor/workspace helpers
        "$mod CTRL, F, fullscreenstate, 0 2"
        "$mod SHIFT ALT, Left, movecurrentworkspacetomonitor, l"
        "$mod SHIFT ALT, Right, movecurrentworkspacetomonitor, r"
        "$mod SHIFT ALT, Up, movecurrentworkspacetomonitor, u"
        "$mod SHIFT ALT, Down, movecurrentworkspacetomonitor, d"
        "$mod CTRL, A, exec, ${pkgs.pavucontrol}/bin/pavucontrol"
        "$mod CTRL, B, exec, ${pkgs.blueman}/bin/blueman-manager"
        "$mod CTRL, T, exec, ${terminal} -e ${pkgs.btop}/bin/btop"

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
        # swayosd-client wraps the underlying tool and pops an on-screen overlay.
        ", XF86AudioRaiseVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume lower"
        ", XF86AudioMute,        exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"
        ", XF86AudioMicMute,     exec, ${pkgs.swayosd}/bin/swayosd-client --input-volume mute-toggle"
        ", XF86MonBrightnessUp,   exec, ${pkgs.swayosd}/bin/swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, ${pkgs.swayosd}/bin/swayosd-client --brightness lower"
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

      # windowrule rules are emitted via extraConfig below (block syntax).
      # Hyprland 0.54.3 dropped the legacy `windowrule = float, class:...`
      # single-line form that the HM module renders by default.
      windowrule = [ ];

      # layerrule = [ ];  # Hyprland 0.54.3 dropped legacy `noanim` keyword;
      # re-add when status bar layer animations need taming.
      layerrule = [ ];

      workspace = [];
    };
  };
}
# EOF

