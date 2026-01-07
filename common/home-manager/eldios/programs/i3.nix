{
  pkgs,
  lib,
  config,
  ...
}:
let
  modifier = "Mod4";

  # Force X11 for Electron apps (override any Wayland env from other sessions)
  electronFlags = "--ozone-platform=x11";

  # Terminal
  terminal = "${pkgs.ghostty}/bin/ghostty";

  # Use the unified rofi scripts from rofi.nix
  quick_menu = "rofi-run";
  full_menu = "rofi-drun";
  file_menu = "rofi-filebrowser";
  window_menu = "rofi-window";

  # Modern lockscreen with blur effect
  lockscreen = "${pkgs.i3lock-color}/bin/i3lock-color -c 000000 --blur 5 --clock --indicator --time-str='%H:%M' --date-str='%a, %b %d'";

  # Power menu using wlogout
  powermenu = "${pkgs.wlogout}/bin/wlogout";

  # Mailspring email client
  mail = "mailspring --password-store=\"gnome-libsecret\"";

  # Screenshots
  screenshot_select = "flameshot gui -c";
  screenshot_full = "flameshot gui";

  # Catppuccin Mocha colors for polybar/i3
  colors = {
    base = "#1e1e2e";
    mantle = "#181825";
    crust = "#11111b";
    text = "#cdd6f4";
    subtext0 = "#a6adc8";
    subtext1 = "#bac2de";
    surface0 = "#313244";
    surface1 = "#45475a";
    surface2 = "#585b70";
    overlay0 = "#6c7086";
    blue = "#89b4fa";
    lavender = "#b4befe";
    sapphire = "#74c7ec";
    sky = "#89dceb";
    teal = "#94e2d5";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    peach = "#fab387";
    maroon = "#eba0ac";
    red = "#f38ba8";
    mauve = "#cba6f7";
    pink = "#f5c2e7";
    flamingo = "#f2cdcd";
    rosewater = "#f5e0dc";
  };
in
{
  home = {
    # Force X11 environment for i3 - override system-wide Wayland defaults
    sessionVariables = {
      # Electron/Chromium: force X11
      NIXOS_OZONE_WL = lib.mkForce "0";
      ELECTRON_OZONE_PLATFORM_HINT = lib.mkForce "x11";

      # GTK: force X11 backend
      GDK_BACKEND = lib.mkForce "x11";

      # Qt: force X11 (xcb) platform
      QT_QPA_PLATFORM = lib.mkForce "xcb";

      # Firefox: disable Wayland
      MOZ_ENABLE_WAYLAND = lib.mkForce "0";

      # Wayland-specific vars: unset/disable
      WLR_NO_HARDWARE_CURSORS = lib.mkForce "";
      WAYLAND_DISPLAY = lib.mkForce "";
    };

    packages = with pkgs; [
      # Terminal
      ghostty
      alacritty

      # Wallpaper and theming
      feh
      nitrogen

      # Modern X11 utilities
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      catppuccin-gtk
      catppuccin-kvantum
      dconf
      dracula-theme
      gnome-themes-extra
      gsettings-desktop-schemas
      papirus-icon-theme

      # Clipboard and tools
      xclip
      xdotool
      xsel

      # Display and color management
      arandr
      autorandr
      redshift

      # Notifications
      dunst

      # System tray and utilities
      networkmanagerapplet
      pasystray
      udiskie

      # Polkit for auth dialogs
      polkit_gnome

      # Screenshot tools
      maim
      scrot

      # Lockscreen
      i3lock-color

      # Power menu
      wlogout

      # Qt theming
      qt5.qtbase
      qt6.qtbase
      libsForQt5.qtstyleplugins

      # Polybar dependencies
      font-awesome
      nerd-fonts.jetbrains-mono

      # File manager
      xfce.thunar
      xfce.thunar-volman

      # Brightness control
      brightnessctl

      # Additional utilities
      playerctl
      pavucontrol
    ];
  };

  # Modern picom with blur (matching Hyprland decoration settings)
  services.picom = {
    enable = true;
    package = pkgs.picom;

    backend = "glx";
    vSync = true;

    # Fading (matching Hyprland animation style)
    fade = true;
    fadeDelta = 5;
    fadeSteps = [ 0.03 0.03 ];

    # Opacity (matching Hyprland: active 0.95, inactive 0.85)
    activeOpacity = 1.00;
    inactiveOpacity = 0.95;

    # Blur settings (matching Hyprland blur)
    settings = {
      blur = {
        method = "dual_kawase";
        size = 8;
        strength = 5;
      };
      blur-background = true;
      blur-background-frame = true;
      blur-background-fixed = false;

      # Corner rounding (matching Hyprland rounding = 10)
      corner-radius = 10;
      rounded-corners-exclude = [
        "class_g = 'i3bar'"
        "class_g = 'Polybar'"
      ];

      # Shadow settings
      shadow = true;
      shadow-radius = 12;
      shadow-offset-x = -5;
      shadow-offset-y = -5;
      shadow-opacity = 0.5;
      shadow-exclude = [
        "class_g = 'i3-frame'"
        "class_g = 'Rofi'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      # Dim inactive windows slightly
      inactive-dim = 0.05;

      # Focus settings
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      use-damage = true;
      log-level = "warn";
    };

    opacityRules = [
      "100:class_g = 'Rofi'"
      "100:class_g = 'i3lock'"
      "100:class_g = 'flameshot'"
      "100:class_g = 'Polybar'"
      "95:class_g = 'ghostty' && focused"
      "85:class_g = 'ghostty' && !focused"
      "95:class_g = 'Alacritty' && focused"
      "85:class_g = 'Alacritty' && !focused"
      "95:class_g = 'kitty' && focused"
      "85:class_g = 'kitty' && !focused"
    ];
  };

  # Polybar configuration
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
      nlSupport = true;
    };
    script = ''
      # Kill existing polybar instances
      ${pkgs.psmisc}/bin/killall -q polybar || true
      # Wait for processes to shut down
      while ${pkgs.procps}/bin/pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
      # Launch bars on both monitors
      MONITOR=DisplayPort-1 polybar --reload main &
      polybar --reload secondary &
    '';
    settings = {
      "colors" = {
        background = colors.base;
        background-alt = colors.surface0;
        foreground = colors.text;
        primary = colors.blue;
        secondary = colors.lavender;
        alert = colors.red;
        disabled = colors.overlay0;
        green = colors.green;
        yellow = colors.yellow;
        red = colors.red;
        blue = colors.blue;
        magenta = colors.mauve;
        cyan = colors.teal;
      };

      "bar/main" = {
        monitor = "\${env:MONITOR:}";
        width = "100%";
        height = "28pt";
        radius = 0;
        dpi = 0;

        background = "\${colors.background}";
        foreground = "\${colors.foreground}";

        line-size = "3pt";

        border-size = "0pt";
        border-color = "#00000000";

        padding-left = 1;
        padding-right = 1;

        module-margin = 1;

        separator = "|";
        separator-foreground = "\${colors.disabled}";

        font-0 = "JetBrainsMono Nerd Font:size=11;2";
        font-1 = "JetBrainsMono Nerd Font:size=14;3";
        font-2 = "Font Awesome 6 Free:style=Solid:size=11;2";

        modules-left = "i3";
        modules-center = "date";
        modules-right = "filesystem pulseaudio memory cpu network tray";

        cursor-click = "pointer";
        cursor-scroll = "ns-resize";

        enable-ipc = true;

        tray-position = "right";
        tray-padding = 2;

        wm-restack = "i3";
        override-redirect = false;
      };

      # Secondary bar for HDMI monitor (no tray to avoid conflict)
      "bar/secondary" = {
        "inherit" = "bar/main";
        monitor = "HDMI-A-0";
        tray-position = "none";
      };

      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        show-urgent = true;
        strip-wsnumbers = false;
        index-sort = true;
        enable-click = true;
        enable-scroll = true;
        wrapping-scroll = false;
        reverse-scroll = false;
        fuzzy-match = true;

        format = "<label-state> <label-mode>";

        label-mode = "%mode%";
        label-mode-padding = 2;
        label-mode-foreground = "\${colors.background}";
        label-mode-background = "\${colors.alert}";

        label-focused = "%index%";
        label-focused-background = "\${colors.background-alt}";
        label-focused-underline = "\${colors.primary}";
        label-focused-padding = 2;

        label-unfocused = "%index%";
        label-unfocused-padding = 2;

        label-visible = "%index%";
        label-visible-background = "\${colors.background-alt}";
        label-visible-padding = 2;

        label-urgent = "%index%";
        label-urgent-background = "\${colors.alert}";
        label-urgent-padding = 2;
      };

      "module/filesystem" = {
        type = "internal/fs";
        interval = 25;
        mount-0 = "/";
        label-mounted = " %percentage_used%%";
        label-unmounted = " %mountpoint% not mounted";
        label-unmounted-foreground = "\${colors.disabled}";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume-prefix = "󰕾 ";
        format-volume-prefix-foreground = "\${colors.primary}";
        format-volume = "<label-volume>";
        label-volume = "%percentage%%";
        label-muted = "󰖁 muted";
        label-muted-foreground = "\${colors.disabled}";
        click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = "󰍛 ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage_used%%";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = "󰻠 ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage%%";
      };

      "module/network" = {
        type = "internal/network";
        interface-type = "wired";
        interval = 5;
        format-connected = "<label-connected>";
        format-disconnected = "<label-disconnected>";
        label-connected = "󰈀 %local_ip%";
        label-disconnected = "󰈂 disconnected";
        label-disconnected-foreground = "\${colors.disabled}";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%a %b %d";
        time = "%H:%M:%S";
        label = "󰃰 %date%  󰅐 %time%";
        label-foreground = "\${colors.foreground}";
      };

      "module/tray" = {
        type = "internal/tray";
        tray-spacing = "8pt";
      };

      "settings" = {
        screenchange-reload = true;
        pseudo-transparency = true;
      };
    };
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    config = {
      inherit modifier;

      # Default terminal
      terminal = terminal;

      # Startup applications
      startup = [
        # CRITICAL: Set X11 environment for D-Bus and systemd services FIRST
        # This overrides any Wayland vars from system config
        {
          command = ''
            ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
              DISPLAY \
              GDK_BACKEND=x11 \
              QT_QPA_PLATFORM=xcb \
              NIXOS_OZONE_WL=0 \
              ELECTRON_OZONE_PLATFORM_HINT=x11 \
              MOZ_ENABLE_WAYLAND=0 \
              XDG_CURRENT_DESKTOP=i3 \
              XDG_SESSION_TYPE=x11 \
              XDG_SESSION_DESKTOP=i3
          '';
          always = true;
          notification = false;
        }
        # Polybar (launched via home-manager service, but ensure it's running)
        {
          command = "systemctl --user restart polybar";
          always = true;
          notification = false;
        }
        # Monitor configuration via autorandr (more reliable than hardcoded xrandr)
        {
          command = "${pkgs.autorandr}/bin/autorandr --change";
          always = true;
          notification = false;
        }
        # Notification daemon
        {
          command = "${pkgs.dunst}/bin/dunst";
          always = false;
          notification = false;
        }
        # Wallpaper with variety (fallback to feh if variety fails)
        {
          command = "${pkgs.variety}/bin/variety || ${pkgs.feh}/bin/feh --bg-fill --randomize ~/Pictures/Wallpapers/";
          always = false;
          notification = false;
        }
        # Polkit agent for auth dialogs
        {
          command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          always = false;
          notification = false;
        }
        # Auto-mount removable media
        {
          command = "${pkgs.udiskie}/bin/udiskie --tray";
          always = false;
          notification = false;
        }
        # Network manager applet
        {
          command = "${pkgs.networkmanagerapplet}/bin/nm-applet";
          always = false;
          notification = false;
        }
        # Clipboard manager
        {
          command = "${pkgs.clipit}/bin/clipit";
          always = false;
          notification = false;
        }
        # Compositor (picom started via home-manager service)
        {
          command = "systemctl --user restart picom";
          always = true;
          notification = false;
        }
      ];

      # Gaps settings
      gaps = {
        inner = 2;
        outer = 3;
        smartBorders = "on";
        smartGaps = false; # Keep gaps even with single window (like Hyprland)
      };

      # Window settings
      window = {
        border = 2;
        hideEdgeBorders = "smart";
        titlebar = false;

        # Floating window rules
        commands = [
          # System utilities
          { command = "floating enable"; criteria = { class = "nm-connection-editor"; }; }
          { command = "floating enable"; criteria = { class = "Nm-connection-editor"; }; }
          { command = "floating enable"; criteria = { class = "blueman-manager"; }; }
          { command = "floating enable"; criteria = { class = "Blueman-manager"; }; }

          # GNOME apps
          { command = "floating enable"; criteria = { class = "org.gnome.Calculator"; }; }
          { command = "floating enable"; criteria = { class = "Gnome-calculator"; }; }
          { command = "floating enable, resize set 900 600"; criteria = { class = "org.gnome.Nautilus"; }; }
          { command = "floating enable"; criteria = { class = "org.gnome.Settings"; }; }

          # File managers
          { command = "floating enable, resize set 1000 700"; criteria = { class = "Thunar"; }; }
          { command = "floating enable, resize set 1000 700"; criteria = { class = "thunar"; }; }
          { command = "floating enable, resize set 1000 700"; criteria = { class = "Pcmanfm"; }; }

          # Media
          { command = "floating enable, sticky enable"; criteria = { title = "Picture-in-Picture"; }; }
          { command = "floating enable, sticky enable"; criteria = { title = "Picture in picture"; }; }
          { command = "floating enable"; criteria = { class = "mpv"; }; }
          { command = "floating enable"; criteria = { class = "Sxiv"; }; }
          { command = "floating enable"; criteria = { class = "feh"; }; }

          # Development
          { command = "floating enable"; criteria = { class = "jetbrains-toolbox"; }; }
          { command = "floating enable"; criteria = { title = "splash"; }; }

          # Chat/Communication (floating for quick access)
          { command = "floating enable, resize set 400 600"; criteria = { class = "telegram-desktop"; }; }

          # Misc
          { command = "floating enable, border none"; criteria = { class = "screenkey"; }; }
          { command = "floating enable"; criteria = { window_role = "pop-up"; }; }
          { command = "floating enable"; criteria = { window_role = "task_dialog"; }; }
          { command = "floating enable"; criteria = { window_role = "bubble"; }; }
          { command = "floating enable"; criteria = { window_role = "dialog"; }; }
          { command = "floating enable"; criteria = { window_type = "dialog"; }; }
          { command = "floating enable"; criteria = { window_type = "menu"; }; }

          # Assign apps to workspaces
          { command = "move to workspace number 2"; criteria = { class = "firefox"; }; }
          { command = "move to workspace number 2"; criteria = { class = "Firefox"; }; }
          { command = "move to workspace number 3"; criteria = { class = "Code"; }; }
          { command = "move to workspace number 4"; criteria = { class = "Slack"; }; }
          { command = "move to workspace number 4"; criteria = { class = "discord"; }; }
          { command = "move to workspace number 5"; criteria = { class = "Spotify"; }; }
        ];
      };

      # Workspace assignments
      assigns = { };

      # Resize mode
      modes.resize = {
        "h" = "resize shrink width 20 px";
        "j" = "resize grow height 20 px";
        "k" = "resize shrink height 20 px";
        "l" = "resize grow width 20 px";
        "Shift+h" = "resize shrink width 100 px";
        "Shift+j" = "resize grow height 100 px";
        "Shift+k" = "resize shrink height 100 px";
        "Shift+l" = "resize grow width 100 px";
        "Escape" = "mode default";
        "Return" = "mode default";
      };

      keybindings = {
        # Workspaces with back-and-forth
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

        # Move container to workspace
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

        # Move container to workspace and follow
        "${modifier}+Ctrl+1" = "move container to workspace number 1; workspace number 1";
        "${modifier}+Ctrl+2" = "move container to workspace number 2; workspace number 2";
        "${modifier}+Ctrl+3" = "move container to workspace number 3; workspace number 3";
        "${modifier}+Ctrl+4" = "move container to workspace number 4; workspace number 4";
        "${modifier}+Ctrl+5" = "move container to workspace number 5; workspace number 5";
        "${modifier}+Ctrl+6" = "move container to workspace number 6; workspace number 6";
        "${modifier}+Ctrl+7" = "move container to workspace number 7; workspace number 7";
        "${modifier}+Ctrl+8" = "move container to workspace number 8; workspace number 8";
        "${modifier}+Ctrl+9" = "move container to workspace number 9; workspace number 9";
        "${modifier}+Ctrl+0" = "move container to workspace number 10; workspace number 10";

        # Focus (vim-style)
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+a" = "focus parent";
        "${modifier}+c" = "focus child";
        "${modifier}+u" = "[urgent=latest] focus"; # Focus urgent window

        # Move windows
        "${modifier}+Shift+h" = "move left 30 px";
        "${modifier}+Shift+j" = "move down 30 px";
        "${modifier}+Shift+k" = "move up 30 px";
        "${modifier}+Shift+l" = "move right 30 px";

        # Resize with Alt
        "${modifier}+Mod1+h" = "resize shrink width 20 px";
        "${modifier}+Mod1+j" = "resize grow height 20 px";
        "${modifier}+Mod1+k" = "resize shrink height 20 px";
        "${modifier}+Mod1+l" = "resize grow width 20 px";
        "${modifier}+Shift+Mod1+h" = "resize shrink width 100 px";
        "${modifier}+Shift+Mod1+j" = "resize grow height 100 px";
        "${modifier}+Shift+Mod1+k" = "resize shrink height 100 px";
        "${modifier}+Shift+Mod1+l" = "resize grow width 100 px";

        # Window cycling
        "${modifier}+n" = "focus next";
        "${modifier}+p" = "focus prev";
        "${modifier}+Shift+n" = "swap container with next";
        "${modifier}+Shift+p" = "swap container with prev";

        # Monitor cycling
        "${modifier}+Tab" = "focus output right";
        "${modifier}+Shift+Tab" = "focus output left";
        "${modifier}+Ctrl+h" = "move workspace to output left";
        "${modifier}+Ctrl+l" = "move workspace to output right";

        # Back and forth
        "${modifier}+grave" = "workspace back_and_forth";
        "${modifier}+Shift+grave" = "move container to workspace back_and_forth; workspace back_and_forth";

        # Applications
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "exec ${full_menu}";
        "${modifier}+Shift+d" = "exec ${quick_menu}";
        "${modifier}+Shift+e" = "exec ${file_menu}";
        "${modifier}+Shift+w" = "exec ${window_menu}";
        "${modifier}+Shift+m" = "exec ${mail}";
        "${modifier}+b" = "exec firefox";
        "${modifier}+Shift+f" = "exec ${pkgs.xfce.thunar}/bin/thunar";

        # Screenshots
        "${modifier}+Shift+s" = "exec ${screenshot_select}";
        "${modifier}+Shift+a" = "exec ${screenshot_full}";
        "Print" = "exec ${screenshot_select}";

        # Window management
        "${modifier}+q" = "kill";
        "${modifier}+Shift+c" = "kill";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+Shift+t" = "sticky toggle";
        "${modifier}+Shift+b" = "border toggle"; # Toggle border

        # Scratchpad
        "${modifier}+minus" = "scratchpad show";
        "${modifier}+Shift+minus" = "move scratchpad";

        # Layout controls
        "${modifier}+x" = "layout toggle split";
        "${modifier}+e" = "layout toggle splitv splith";
        "${modifier}+w" = "layout tabbed";
        "${modifier}+s" = "layout stacking";
        "${modifier}+v" = "split v";
        "${modifier}+Shift+v" = "split h";
        "${modifier}+r" = "mode resize";
        "${modifier}+t" = "layout toggle all"; # Cycle through all layouts

        # Gaps control
        "${modifier}+g" = "gaps inner current plus 5";
        "${modifier}+Shift+g" = "gaps inner current minus 5";
        "${modifier}+Ctrl+g" = "gaps inner current set 5; gaps outer current set 10";

        # System controls
        "${modifier}+Ctrl+q" = "exec ${lockscreen}";
        "${modifier}+Ctrl+Shift+q" = "exec ${powermenu}";
        "${modifier}+Shift+r" = "reload";
        "${modifier}+Shift+Ctrl+r" = "restart";

        # Media keys (wireplumber)
        "XF86AudioRaiseVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
        "XF86AudioStop" = "exec ${pkgs.playerctl}/bin/playerctl stop";

        # Quick volume (shift for bigger steps)
        "${modifier}+equal" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "${modifier}+Shift+equal" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+";
        "${modifier}+bracketleft" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "${modifier}+Shift+bracketleft" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-";

        # Window opacity control (picom-trans)
        "${modifier}+o" = "exec ${pkgs.picom}/bin/picom-trans -c -5";
        "${modifier}+Shift+o" = "exec ${pkgs.picom}/bin/picom-trans -c +5";
        "${modifier}+Ctrl+o" = "exec ${pkgs.picom}/bin/picom-trans -c 100";
      };

      # Bar configuration (use polybar or i3bar)
      bars = [ ]; # Disable default bar, use polybar/waybar equivalent
    };

    # Extra config
    extraConfig = ''
      # Mouse bindings
      floating_modifier ${modifier}

      # Focus behavior
      focus_follows_mouse yes
      mouse_warping output
      focus_wrapping no
      focus_on_window_activation smart

      # Workspace back and forth
      workspace_auto_back_and_forth yes

      # Default orientation for new workspaces
      default_orientation horizontal

      # Hide borders when only one window
      hide_edge_borders smart_no_gaps

      # Popup handling during fullscreen
      popup_during_fullscreen smart

      # Urgent workspace behavior
      force_display_urgency_hint 500 ms

      # Default layout for new containers
      workspace_layout default

      # Border colors (catppuccin mocha)
      client.focused          ${colors.blue} ${colors.base} ${colors.text} ${colors.lavender} ${colors.blue}
      client.focused_inactive ${colors.surface1} ${colors.base} ${colors.text} ${colors.surface1} ${colors.surface1}
      client.unfocused        ${colors.surface0} ${colors.base} ${colors.subtext0} ${colors.surface0} ${colors.surface0}
      client.urgent           ${colors.red} ${colors.base} ${colors.text} ${colors.red} ${colors.red}
      client.placeholder      ${colors.crust} ${colors.crust} ${colors.text} ${colors.crust} ${colors.crust}
      client.background       ${colors.base}

      # Workspace names with icons (optional - uncomment if you want icons)
      # set $ws1 "1: "
      # set $ws2 "2: "
      # set $ws3 "3: "
      # set $ws4 "4: "
      # set $ws5 "5: "

      # Title format
      for_window [class=".*"] title_format "<b>%title</b>"

      # No title bars for all windows
      default_border pixel 2
      default_floating_border pixel 2

      # Specific window settings
      for_window [class="ghostty"] border pixel 2
      for_window [class="Alacritty"] border pixel 2
      for_window [class="kitty"] border pixel 2
      for_window [urgent=latest] focus
    '';
  };
}

# vim: set ts=2 sw=2 et ai list nu

