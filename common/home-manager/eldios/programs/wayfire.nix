{ pkgs
, config
, lib
, ...
}:
let
  # Preferred terminal emulator
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
      # Supporting packages
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
      xdg-desktop-portal-wlr
      xdg-utils
      ydotool
    ];
  };

  # Enable Wayfire window manager
  wayland.windowManager.wayfire = {
    enable = true;
    package = pkgs.wayfire;
    plugins = with pkgs.wayfirePlugins; [
      wayfire-plugins-extra
      wcm
      wf-shell
      windecor
      firedecor
      wayfire-shadows
      focus-request
      wwp-switcher
    ];

    # Enable XWayland support
    xwayland.enable = true;

    # Enable systemd integration
    systemd.enable = true;

    # Enable wf-shell components
    wf-shell = {
      enable = true;
    };

    # Wayfire configuration
    settings = {
      # Core settings
      core = {
        plugins = "autostart vswitch move resize animate grid expo cube switcher place decoration alpha-fade scale fisheye zoom wm-actions blur command wrot invert vswipe wobbly window-rules";

        # Virtual workspace grid size
        vwidth = 3;
        vheight = 3;

        # Rendering settings
        max_render_time = 7;
      };

      # Output (monitor) configuration
      output = {
        # Primary ultrawide monitor (left) - HDMI-A-1
        "HDMI-A-1" = "3440x1440@59.94 0,0 normal";
        # Secondary monitor (right) - HDMI-A-2
        "HDMI-A-2" = "2560x1440@143.87 3440,0 normal";
      };

      # Input configuration
      input = {
        kb_layout = "us";
        mouse_accel_profile = "flat";
        tap_to_click = true;
        natural_scroll = false;
        disable_while_typing = true;
        drag_lock = true;
        mouse_cursor_speed = 0.5;
      };

      # Autostart applications
      autostart = {
        # DBus environment
        dbus_env = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT";

        # Start Waybar
        waybar = "${pkgs.waybar}/bin/waybar";

        # Start notification daemon
        mako = "${pkgs.mako}/bin/mako";

        # Start wallpaper manager
        variety = "${pkgs.variety}/bin/variety";

        # Environment variables
        env_NIXOS_OZONE_WL = 1;
        env_MOZ_ENABLE_WAYLAND = 1;
        env_QT_QPA_PLATFORM = "wayland";
        env_XDG_CURRENT_DESKTOP = "Wayfire";
        env_XDG_SESSION_TYPE = "wayland";
        env_XDG_SESSION_DESKTOP = "Wayfire";
        env_ELECTRON_OZONE_PLATFORM_HINT = "wayland";
        env_WAYLAND_DISPLAY = "wayland-1";
      };

      # Window decoration
      decoration = {
        border_size = 2;
        active_color = lib.mkDefault "${config.lib.stylix.colors.base0D}";
        inactive_color = lib.mkDefault "${config.lib.stylix.colors.base03}";
        title_height = 0;
        button_order = "minimize maximize close";
      };

      # Window rules
      "window-rules" = {
        "pavucontrol" = "floating";
        "nm-connection-editor" = "floating";
        "org.gnome.Calculator" = "floating";
        "org.gnome.Nautilus" = "floating";
        "org.gnome.Settings" = "floating";
        "Picture-in-Picture" = "floating";
        "screenkey" = "floating,noborder";
      };

      # Blur for transparent windows
      blur = {
        method = "kawase";
        blur_passes = 3;
        saturation = 0.9;
        brightness = 0.8;
        gaussian_degrade = true;
        bokeh_degrade = true;
        kawase_offset = 8.0;
        kawase_degrade_mode = "normal";
        kawase_iterations = 3;
        noise = 0.01;
        contrast = 0.9;
      };

      # Alpha (transparency) settings
      alpha = {
        min_value = 0.85;
        modifier = "super";
      };

      # Animation settings
      animate = {
        open_animation = "zoom";
        close_animation = "zoom";
        duration = 200;
        startup_duration = 300;
        enabled_for = "(type equals \"toplevel\" | type equals \"x-or\")";
      };

      # Workspace grid
      vswitch = {
        binding_left = "super_h";
        binding_down = "super_j";
        binding_up = "super_k";
        binding_right = "super_l";
        wraparound = false;
        duration = 300;

        # Workspace bindings (1-10)
        binding_1 = "super_1";
        binding_2 = "super_2";
        binding_3 = "super_3";
        binding_4 = "super_4";
        binding_5 = "super_5";
        binding_6 = "super_6";
        binding_7 = "super_7";
        binding_8 = "super_8";
        binding_9 = "super_9";
        binding_0 = "super_0";
      };

      # Window movement
      move = {
        activate = "super_BTN_LEFT";
        enable_snap = true;
        enable_snap_off = true;
        snap_threshold = 10;
        join_views = false;
      };

      # Window resizing
      resize = {
        activate = "super_BTN_RIGHT";
      };

      # Expo (workspace overview)
      expo = {
        toggle = "super_e";
        background = lib.mkDefault "${config.lib.stylix.colors.base00}";
        duration = 300;
        offset = 10;
      };

      # Scale (window overview)
      scale = {
        toggle = "super_tab";
        duration = 300;
        spacing = 50;
        inactive_alpha = 0.7;
        title_overlay = true;
        middle_click_close = true;
      };

      # Zoom
      zoom = {
        modifier = "super";
        speed = 0.01;
        smoothing_duration = 300;
      };

      # Wobbly windows
      wobbly = {
        friction = 3.0;
        spring_k = 8.0;
        grid_resolution = 6;
      };

      # Command bindings
      command = {
        # Terminal
        binding_terminal = "super_return";
        command_terminal = terminal;

        # Application launchers
        binding_launcher = "super_d";
        command_launcher = full_menu;

        binding_quick_launcher = "super_shift_d";
        command_quick_launcher = quick_menu;

        binding_file_browser = "super_shift_e";
        command_file_browser = file_menu;

        binding_window_menu = "super_shift_w";
        command_window_menu = window_menu;

        # Mail client
        binding_mail = "super_shift_m";
        command_mail = mail;

        # System controls
        binding_lock = "super_ctrl_q";
        command_lock = lockscreen;

        binding_power = "super_ctrl_shift_q";
        command_power = powermenu;

        # Screenshots
        binding_screenshot_select = "super_shift_s";
        command_screenshot_select = screenshot_select;

        binding_screenshot_full = "super_shift_a";
        command_screenshot_full = screenshot_full;

        # Window management
        binding_kill = "super_shift_c";
        command_kill = "killall -9 $(slurp -f %a)";

        # Media keys
        binding_volume_up = "XF86AudioRaiseVolume";
        command_volume_up = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";

        binding_volume_down = "XF86AudioLowerVolume";
        command_volume_down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";

        binding_mute = "XF86AudioMute";
        command_mute = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";

        binding_brightness_up = "XF86MonBrightnessUp";
        command_brightness_up = "sudo ${pkgs.light}/bin/light -A 5";

        binding_brightness_down = "XF86MonBrightnessDown";
        command_brightness_down = "sudo ${pkgs.light}/bin/light -U 5";

        binding_play_pause = "XF86AudioPlay";
        command_play_pause = "${pkgs.playerctl}/bin/playerctl play-pause";

        binding_next = "XF86AudioNext";
        command_next = "${pkgs.playerctl}/bin/playerctl next";

        binding_prev = "XF86AudioPrev";
        command_prev = "${pkgs.playerctl}/bin/playerctl previous";
      };

      # Window management actions
      "wm-actions" = {
        toggle_fullscreen = "super_f";
        toggle_always_on_top = "super_t";
        toggle_sticky = "super_p";
        toggle_maximize = "super_m";
        minimize = "super_n";
      };
    };
  };

  # Wayfire env vars are set via env_* in wayfire.ini [core] section
  # Don't use home.sessionVariables - it persists to other sessions like i3
}
