{ pkgs, config, ... }:

let
  terminal = "${pkgs.ghostty}/bin/ghostty";

  # Rofi application launcher
  quick_menu = "rofi-run";
  full_menu = "rofi-drun";
  file_menu = "rofi-filebrowser";
  window_menu = "rofi-window";

  # Power menu using wlogout
  powermenu = "${pkgs.wlogout}/bin/wlogout";
  # Screen locker
  lockscreen = "${pkgs.swaylock-effects}/bin/swaylock -f -c 000000 --clock --effect-blur 7x5";
  # Mail client
  mail = "mailspring --password-store='gnome-libsecret'";

  # Screenshot tools (Wayland-native)
  screenshot_select = "${pkgs.grimblast}/bin/grimblast --notify copy area";
  screenshot_full = "${pkgs.grimblast}/bin/grimblast --notify copy screen";

  # Day/night screen adjustment
  daynightscreen = "${pkgs.wlsunset}/bin/wlsunset -l 43.841667 -L 10.502778";

  # Stylix colors (hex without # prefix)
  colors = config.lib.stylix.colors;

  # Helper: convert stylix hex color (e.g. "1e1e2e") to MangoWC RGBA format (e.g. "0x1e1e2eff")
  toMangoColor = hex: "0x${hex}ff";
  toMangoColorAlpha = hex: alpha: "0x${hex}${alpha}";
in
{
  home = {
    packages = with pkgs; [
      # Wayland essentials for MangoWC
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      bemenu
      clipman
      dconf
      dracula-theme
      eww
      fuseiso
      fuzzel
      gammastep
      geoclue2
      ghostty
      glpaper
      gnome-themes-extra
      grim
      grimblast
      gsettings-desktop-schemas
      kitty
      lavalauncher
      libva-utils
      mako
      pinentry-bemenu
      polkit_gnome
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      shotman
      slurp
      swaybg
      swaylock-effects
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
      wshowkeys
      wtype
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-utils
      ydotool
    ];
  };

  # MangoWC config file (~/.config/mango/config.conf)
  home.file.".config/mango/config.conf" = {
    text = ''
      # ╔══════════════════════════════════════════════════════════════════════╗
      # ║                     MangoWC Configuration                          ║
      # ║              Managed by NixOS Home Manager (Nix)                   ║
      # ╚══════════════════════════════════════════════════════════════════════╝
      #
      # MangoWC is a dwm-inspired Wayland compositor built on dwl + scenefx.
      # Think of it as "dwm for Wayland" — lightweight, fast, tiling-first,
      # but with modern eye candy (blur, shadows, animations, rounded corners).
      #
      # Docs:   https://mangowc.vercel.app/docs
      # Wiki:   https://github.com/DreamMaoMao/mangowc/wiki
      # Config: https://github.com/DreamMaoMao/mangowc/wiki/configoption
      # Binds:  https://github.com/DreamMaoMao/mangowc/wiki/bindaction
      #
      # HOT RELOAD: MangoWC supports hot-reloading config without restarting.
      # After editing, press Super+R (or Super+Shift+Ctrl+R) to apply changes.
      #
      # ┌──────────────────────────────────────────────────────────────────────┐
      # │                    CORE CONCEPTS                                    │
      # └──────────────────────────────────────────────────────────────────────┘
      #
      # TAGS vs WORKSPACES
      # ~~~~~~~~~~~~~~~~~~
      # MangoWC uses TAGS (1-9), NOT traditional workspaces. The difference:
      #
      #   Workspaces (i3/Sway): Each window lives on exactly ONE workspace.
      #     Switching workspace = switching to a completely different set of
      #     windows. Workspaces are like rooms — you're in one room at a time.
      #
      #   Tags (dwm/MangoWC): Each window has one or more TAGS (like labels).
      #     You VIEW one or more tags at a time. A window tagged [1][3] is
      #     visible when viewing tag 1, tag 3, or both. Tags are like filters.
      #
      # In practice, if you use Super+1..9 to switch and Super+Shift+1..9
      # to move windows, tags behave just like workspaces. But you CAN:
      #   - View multiple tags simultaneously (toggleview)
      #   - Tag a window with multiple tags (toggletag) so it appears on several
      #   - Make a window "global" (visible on ALL tags) with Super+Shift+T
      #
      # TAG NAVIGATION
      # ~~~~~~~~~~~~~~
      #   Super + 1..9               → View tag N (like switching workspace)
      #   Super + Shift + 1..9       → Move focused window to tag N
      #   Super + Ctrl + H/L         → Go to prev/next tag that HAS windows
      #   Super + Scroll Up/Down     → Same (prev/next occupied tag)
      #   4-finger swipe Left/Right  → Same (trackpad gesture)
      #
      # The "_have_client" variants skip empty tags — so you only land on tags
      # that actually have windows, which is why tags 1-2 feel "rolling" (they
      # have windows) while 3+ feel empty (nothing on them, so they're skipped).
      #
      # LAYOUTS
      # ~~~~~~~
      # MangoWC supports multiple tiling layouts, switchable per-tag:
      #
      #   tile     → Master-stack: one big window (master) on the left,
      #              remaining windows stacked on the right. Classic dwm layout.
      #              Master ratio adjustable with Super+[ and Super+].
      #              Number of masters adjustable with Super+= and Super+Shift+=.
      #
      #   scroller → Horizontal scrolling layout. Windows are placed side by
      #              side and you scroll through them. Great for wide monitors
      #              or when you have many windows. Each window's width is
      #              controlled by "proportion" (Super+Shift+[ / ]).
      #
      #   monocle  → One window at a time, fullscreen-ish. Switch between
      #              windows with Super+J/K. Good for focused work.
      #
      #   grid     → Windows arranged in an auto-calculated grid. Good when
      #              you have many similar windows (terminals, etc.).
      #
      # Switch layout:  Super+N (cycle), or Super+T/S/W/G for direct access.
      # Each tag remembers its own layout independently.
      #
      # KEY MODES
      # ~~~~~~~~~
      # MangoWC has a modal keybinding system (like vim):
      #
      #   "common"  → Bindings that work in ALL modes (e.g., reload config)
      #   "default" → Normal operation mode, all main keybindings
      #   "resize"  → Dedicated resize mode (enter with Super+Alt+R, exit
      #               with Escape/Enter). In this mode, plain H/J/K/L resize
      #               windows without needing modifier keys.
      #
      # SCRATCHPAD
      # ~~~~~~~~~~
      # A hidden floating window you can toggle on/off:
      #
      #   Super + -           → Toggle scratchpad visibility
      #   Super + Shift + -   → Launch a new scratchpad terminal (ghostty)
      #
      # "Named scratchpad" = a specific app matched by appid. When toggled,
      # MangoWC launches it if not running, or shows/hides it if it is.
      #
      # OVERVIEW MODE
      # ~~~~~~~~~~~~~
      # Shows all windows on the current tag as a grid for quick navigation:
      #
      #   Super + Tab             → Toggle overview
      #   3-finger swipe Up/Down  → Toggle overview
      #   Hot corner (bottom-left, 10px) → Enter overview
      #
      # In overview: left-click to focus, right-click to close a window.
      #
      # WINDOW SWALLOWING
      # ~~~~~~~~~~~~~~~~~
      # When a terminal (ghostty/kitty/etc.) launches a GUI app, the terminal
      # window is hidden and replaced by the GUI app. When the GUI app closes,
      # the terminal reappears. Configured via isterm/noswallow window rules.
      #
      # ┌──────────────────────────────────────────────────────────────────────┐
      # │                    STYLE DECISIONS                                  │
      # └──────────────────────────────────────────────────────────────────────┘
      #
      # This config aims for visual consistency with Hyprland/Sway configs in
      # this dotfiles repo. Key choices:
      #
      #   - Colors: All from Stylix (base16 scheme), so they match the global
      #     theme across all apps (terminal, waybar, gtk, etc.)
      #   - Gaps/radius/opacity: Matched to Hyprland settings for consistency
      #   - Animations: Slightly faster than defaults for a snappy feel
      #   - Blur: Enabled on windows AND layers (waybar gets blur too)
      #   - Vim keybindings: H/J/K/L everywhere for muscle memory
      #   - CapsLock → Escape: XKB option for vim users
      #   - HiDPI: Scale 2x on eDP-1 (laptop display), cursor size 48
      #
      # ┌──────────────────────────────────────────────────────────────────────┐
      # │                    KEYBINDING CHEAT SHEET                           │
      # └──────────────────────────────────────────────────────────────────────┘
      #
      # APPS
      #   Super + Enter           Terminal (ghostty)
      #   Super + D               App launcher (rofi drun)
      #   Super + Shift + D       Command runner (rofi run)
      #   Super + Shift + E       File browser (rofi)
      #   Super + Shift + W       Window switcher (rofi)
      #   Super + Shift + M       Mail client
      #
      # WINDOWS
      #   Super + Shift + C       Close window
      #   Super + F               Fullscreen
      #   Super + Space            Toggle maximize
      #   Super + Shift + Space   Toggle floating
      #   Super + Shift + T       Toggle global (visible on all tags)
      #   Super + Shift + Enter   Zoom (swap with master)
      #
      # FOCUS (vim-style)
      #   Super + H/J/K/L         Focus left/down/up/right
      #   Super + Shift + H/J/K/L Swap window left/down/up/right
      #   Super + Tab             Overview mode
      #
      # TAGS
      #   Super + 1-9             View tag
      #   Super + Shift + 1-9     Move window to tag
      #   Super + Ctrl + H/L      Prev/next occupied tag
      #   Super + 0               Toggle gaps
      #
      # LAYOUTS
      #   Super + N               Cycle layout
      #   Super + T               Tile layout
      #   Super + S               Scroller layout
      #   Super + W               Monocle layout
      #   Super + G               Grid layout
      #   Super + [ / ]           Shrink/grow master area
      #   Super + = / Shift+=     Add/remove master window
      #
      # RESIZE
      #   Super + Alt + H/J/K/L       Resize (small step)
      #   Super + Shift + Alt + H/J/K/L  Resize (big step)
      #   Super + Alt + R             Enter resize mode (then plain H/J/K/L)
      #
      # FLOATING
      #   Super + Ctrl + Shift + H/J/K/L  Move floating window
      #   Super + Mouse Left              Drag to move
      #   Super + Mouse Right             Drag to resize
      #
      # MONITORS
      #   Super + , / .               Focus prev/next monitor
      #   Super + Shift + , / .       Move window to prev/next monitor
      #
      # SCRATCHPAD
      #   Super + -                   Toggle scratchpad
      #   Super + Shift + -           New scratchpad terminal
      #
      # SYSTEM
      #   Super + R                   Reload config
      #   Super + Ctrl + Q            Lock screen
      #   Super + Ctrl + Shift + Q    Power menu (wlogout)
      #   Super + Shift + S           Screenshot (area)
      #   Super + Shift + A           Screenshot (full)
      #
      # TRACKPAD GESTURES
      #   3-finger swipe L/R          Focus window left/right
      #   3-finger swipe Up/Down      Toggle overview
      #   4-finger swipe L/R          Prev/next occupied tag
      #
      # MEDIA KEYS (work on lockscreen too)
      #   Volume Up/Down/Mute, Brightness Up/Down, Play/Next/Prev
      #

      # =====================================================================
      # Environment Variables
      # =====================================================================
      # These ensure Wayland-native rendering for Qt, GTK, Electron, etc.
      # GDK_BACKEND=wayland,x11 means "try Wayland first, fall back to X11"
      env=NIXOS_OZONE_WL,1
      env=MOZ_ENABLE_WAYLAND,1
      env=QT_QPA_PLATFORM,wayland
      env=QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      env=GDK_BACKEND,wayland,x11
      env=XDG_CURRENT_DESKTOP,wlroots
      env=XDG_SESSION_TYPE,wayland
      env=XDG_SESSION_DESKTOP,mango
      env=ELECTRON_OZONE_PLATFORM_HINT,wayland
      env=SDL_VIDEODRIVER,wayland
      env=_JAVA_AWT_WM_NONREPARENTING,1
      env=XCURSOR_SIZE,48

      # =====================================================================
      # Monitor Rules
      # =====================================================================
      # Desktop (lele8845ace): HDMI-A-1 (left) + DP-2 ultrawide (right)
      monitorrule=name:HDMI-A-1,width:2560,height:1440,refresh:143.972,x:0,y:0,scale:1
      monitorrule=name:DP-2,width:3440,height:1440,refresh:144,x:2560,y:0,scale:1
      # Laptop (eDP-1): HiDPI scale 2x
      monitorrule=name:eDP-1,scale:2

      # =====================================================================
      # Autostart
      # =====================================================================
      # Order matters: dbus env must be set first, then services that depend on it.
      exec-once=${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP GDK_BACKEND NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT
      exec-once=${pkgs.waybar}/bin/waybar
      exec-once=${pkgs.mako}/bin/mako
      # Wallpaper: swww-daemon must start before Variety
      exec-once=${pkgs.swww}/bin/swww-daemon
      exec-once=sleep 1 && ${pkgs.variety}/bin/variety
      # Night light (Lucca, Italy coordinates)
      exec-once=${daynightscreen}
      # Polkit agent (for GUI privilege escalation prompts)
      exec-once=${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
      # Clipboard manager (persists clipboard after app closes)
      exec-once=${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.clipman}/bin/clipman store

      # =====================================================================
      # Appearance / Theming
      # =====================================================================

      # Border width in pixels (thin, just enough to see focus color)
      borderpx=2

      # Gaps between windows (inner) and screen edges (outer)
      # Matched to Hyprland config for visual consistency across WMs
      gappih=5
      gappiv=5
      gappoh=10
      gappov=10

      # Colors — all pulled from Stylix base16 scheme for global theme consistency
      # Format: 0xRRGGBBaa (hex RGBA)
      rootcolor=${toMangoColor colors.base00}
      bordercolor=${toMangoColor colors.base03}
      focuscolor=${toMangoColor colors.base0D}
      urgentcolor=${toMangoColor colors.base08}
      maximizescreencolor=${toMangoColor colors.base0B}
      scratchpadcolor=${toMangoColor colors.base0E}
      globalcolor=${toMangoColor colors.base0C}
      overlaycolor=${toMangoColor colors.base0A}

      # HiDPI cursor (48 = 24 logical px at scale 2)
      cursor_size=48

      # =====================================================================
      # Visual Effects (scenefx)
      # =====================================================================
      # scenefx is the rendering backend that gives MangoWC its eye candy.
      # All of these are optional — set to 0 to disable for performance.

      # Blur: frosted glass effect on semi-transparent windows
      blur=1
      blur_layer=1
      blur_optimized=1
      blur_params_radius=8
      blur_params_num_passes=3
      blur_params_noise=0.02
      blur_params_brightness=0.8
      blur_params_contrast=0.9
      blur_params_saturation=1.2

      # Shadows: drop shadow behind all windows
      shadows=1
      layer_shadows=0
      shadow_only_floating=0
      shadows_size=12
      shadows_blur=15
      shadows_position_x=-5
      shadows_position_y=-5
      shadowscolor=${toMangoColorAlpha "000000" "80"}

      # Rounded corners (matched to Hyprland rounding=10)
      border_radius=10
      no_radius_when_single=0

      # Opacity: focused window slightly transparent, unfocused more so.
      # This lets blur show through and gives depth to the desktop.
      focused_opacity=0.95
      unfocused_opacity=0.85

      # =====================================================================
      # Animations
      # =====================================================================
      # Durations are tuned shorter than defaults for a snappy feel.
      # Bezier curves matched to Hyprland's fadeBezier for consistency.

      animations=1
      layer_animations=1

      # Open: zoom in from small (like macOS), Close: fade out
      animation_type_open=zoom
      animation_type_close=fade
      # Layers (waybar, notifications): slide in, fade out
      layer_animation_type_open=slide
      layer_animation_type_close=fade

      animation_fade_in=1
      animation_fade_out=1
      fadein_begin_opacity=0.3
      fadeout_begin_opacity=0.5

      zoom_initial_ratio=0.3
      zoom_end_ratio=0.85

      # Durations (ms) — lower = snappier
      animation_duration_move=400
      animation_duration_open=350
      animation_duration_tag=250
      animation_duration_close=250
      animation_duration_focus=0

      # Bezier curves (control points: x1,y1,x2,y2)
      # These overshoot slightly for a bouncy/organic feel
      animation_curve_open=0.1,0.9,0.1,1
      animation_curve_move=0.1,0.9,0.1,1
      animation_curve_tag=0.1,0.9,0.1,1
      animation_curve_close=0.08,0.92,0,1
      animation_curve_focus=0.1,0.9,0.1,1
      animation_curve_opafadein=0.1,0.9,0.1,1
      animation_curve_opafadeout=0.5,0.5,0.5,0.5

      # Tag switch animation slides horizontally (1=horizontal, 0=vertical)
      tag_animation_direction=1

      # =====================================================================
      # Layouts
      # =====================================================================

      # circle_layout restricts which layouts Super+N cycles through.
      # Without this, it would cycle ALL built-in layouts including obscure ones.
      circle_layout=tile,scroller,monocle,grid

      # Master-stack layout defaults
      # new_is_master=1: new windows become master (pushed to left/top)
      # mfact=0.55: master takes 55% of screen width
      # nmaster=1: one master window (rest go to stack)
      new_is_master=1
      default_mfact=0.55
      default_nmaster=1
      smartgaps=0

      # Scroller layout defaults
      # structs=20: 20px margin on sides when proportion=1.0
      # proportion=0.9: each window takes 90% of screen width by default
      # prefer_overspread=1: fill empty space rather than leaving gaps
      scroller_structs=20
      scroller_default_proportion=0.9
      scroller_focus_center=0
      scroller_prefer_center=0
      scroller_prefer_overspread=1
      scroller_proportion_preset=0.5,0.8,1.0
      scroller_ignore_proportion_single=1
      scroller_default_proportion_single=1.0

      # =====================================================================
      # Input
      # =====================================================================

      # Keyboard repeat: 600ms delay before repeating, then 25 chars/sec
      repeat_rate=25
      repeat_delay=600
      numlockon=0
      xkb_rules_layout=us
      # CapsLock → Escape (for vim users)
      xkb_rules_options=caps:escape

      # Trackpad (laptop)
      tap_to_click=1
      tap_and_drag=1
      trackpad_natural_scrolling=0
      scroll_method=1
      click_method=1
      drag_lock=1
      disable_while_typing=1
      left_handed=0

      # Mouse
      mouse_natural_scrolling=0
      # accel_profile: 0=none, 1=adaptive, 2=flat
      accel_profile=2
      accel_speed=0.0

      # =====================================================================
      # Focus & Behavior
      # =====================================================================

      # focus_on_activate: when an app requests attention, focus it immediately
      focus_on_activate=1
      # sloppyfocus: focus follows mouse (hover to focus, no click needed)
      sloppyfocus=1
      # warpcursor: move cursor to center of window when focus changes via keyboard
      warpcursor=1
      # Hide cursor after 5 seconds of inactivity
      cursor_hide_timeout=5
      # Allow focus/exchange to cross monitor boundaries with hjkl
      focus_cross_monitor=1
      exchange_cross_monitor=1

      # =====================================================================
      # Overview Mode
      # =====================================================================
      # Hot area: move cursor to bottom-left corner to trigger overview.
      # ov_tab_mode=0: clicking a window in overview focuses it and exits.

      enable_hotarea=1
      hotarea_size=10
      ov_tab_mode=0
      overviewgappi=5
      overviewgappo=30

      # =====================================================================
      # Scratchpad
      # =====================================================================
      # Scratchpad windows appear centered as floating, taking 80%x85% of screen.

      scratchpad_width_ratio=0.8
      scratchpad_height_ratio=0.85

      # =====================================================================
      # System
      # =====================================================================

      # Keep XWayland running (avoids startup delay for X11 apps)
      xwayland_persistence=1
      adaptive_sync=0
      # Let apps (e.g., games) grab all keyboard shortcuts
      allow_shortcuts_inhibit=1
      allow_tearing=0

      # =====================================================================
      # Tag Rules (per-tag defaults)
      # =====================================================================
      # Each tag can have its own default layout, master count, and ratio.
      # These are applied when the tag is first viewed.

      tagrule=id:1,layout_name:tile,nmaster:1,mfact:0.55
      tagrule=id:2,layout_name:tile
      tagrule=id:3,layout_name:tile
      tagrule=id:9,layout_name:tile

      # =====================================================================
      # Window Rules
      # =====================================================================
      # Format: windowrule=property:value,match_field:pattern
      # Match by appid (Wayland) or title. Use `wev` or `mmsg -b` to find appids.

      # --- Float these apps (dialogs, settings, small utilities) ---
      windowrule=isfloating:1,width:400,height:150,appid:lxqt-openssh-askpass
      windowrule=isfloating:1,appid:pavucontrol
      windowrule=isfloating:1,appid:nm-connection-editor
      windowrule=isfloating:1,appid:org.gnome.Calculator
      windowrule=isfloating:1,width:900,height:600,appid:org.gnome.Nautilus
      windowrule=isfloating:1,appid:org.gnome.Settings
      windowrule=isfloating:1,title:Picture-in-Picture
      windowrule=isfloating:1,appid:screenkey
      windowrule=isnoborder:1,appid:screenkey
      windowrule=isfloating:1,appid:blueman-manager
      windowrule=isfloating:1,appid:thunar
      windowrule=isfloating:1,width:1000,height:700,appid:pcmanfm

      # --- Terminal swallowing ---
      # When a terminal spawns a GUI app (e.g., `firefox`), the terminal hides
      # and the GUI app takes its place. When the GUI app exits, terminal returns.
      windowrule=isterm:1,appid:ghostty
      windowrule=isterm:1,appid:kitty
      windowrule=isterm:1,appid:Alacritty
      windowrule=isterm:1,appid:foot

      # These apps should NOT swallow their parent terminal
      windowrule=noswallow:1,appid:firefox
      windowrule=noswallow:1,appid:brave-browser
      windowrule=noswallow:1,appid:chromium-browser

      # --- Force full opacity on media/browser (blur looks bad on video) ---
      windowrule=focused_opacity:1.0,appid:firefox
      windowrule=focused_opacity:1.0,appid:brave-browser
      windowrule=focused_opacity:1.0,appid:chromium-browser
      windowrule=focused_opacity:1.0,appid:mpv
      windowrule=focused_opacity:1.0,appid:vlc

      # --- Named scratchpad terminal ---
      # Launch with Super+Shift+-, toggle with Super+-
      # Matched by appid "ghostty-scratch" (ghostty --class=ghostty-scratch)
      windowrule=isnamedscratchpad:1,width:1280,height:800,appid:ghostty-scratch

      # =====================================================================
      # Layer Rules
      # =====================================================================
      # Layers are surfaces like waybar, notifications, app launchers.

      #layerrule=layer_name:walker,animation_type_open:zoom,animation_type_close:fade
      layerrule=layer_name:waybar,noanim:1
      layerrule=layer_name:notifications,noblur:1

      # =====================================================================
      # Key Modes
      # =====================================================================
      # "common" bindings work in ALL modes (even resize mode).
      # "default" is the normal operation mode.

      keymode=common
      bind=SUPER,r,reload_config,

      keymode=default

      # =====================================================================
      # Key Bindings — Applications
      # =====================================================================
      bind=SUPER,Return,spawn,${terminal}
      bind=SUPER,d,spawn,${full_menu}
      bind=SUPER+SHIFT,d,spawn,${quick_menu}
      bind=SUPER+SHIFT,e,spawn,${file_menu}
      bind=SUPER+SHIFT,w,spawn,${window_menu}
      bind=SUPER+SHIFT,m,spawn,${mail}

      # =====================================================================
      # Key Bindings — System
      # =====================================================================
      bind=SUPER+CTRL,q,spawn,${lockscreen}
      bind=SUPER+CTRL+SHIFT,q,spawn,${powermenu}
      bind=SUPER+SHIFT+CTRL,r,reload_config,

      # Screenshots (grimblast: Wayland-native screenshot tool)
      bind=SUPER+SHIFT,s,spawn,${screenshot_select}
      bind=SUPER+SHIFT,a,spawn,${screenshot_full}

      # =====================================================================
      # Key Bindings — Window Management
      # =====================================================================
      bind=SUPER+SHIFT,c,killclient,
      bind=SUPER,f,togglefullscreen,
      bind=SUPER+SHIFT,space,togglefloating,
      # togglemaximizescreen,0 = maximize without hiding waybar
      bind=SUPER,space,togglemaximizescreen,0
      # Global = window visible on ALL tags (sticky window)
      bind=SUPER+SHIFT,t,toggleglobal,
      bind=SUPER,minus,toggle_scratchpad,
      bind=SUPER+SHIFT,minus,spawn,${terminal} --class=ghostty-scratch

      # =====================================================================
      # Key Bindings — Focus (vim-style H/J/K/L)
      # =====================================================================
      # H/L = directional (cross-monitor if focus_cross_monitor=1)
      # J/K = stack order (within current tag's window list)
      bind=SUPER,h,focusdir,left
      bind=SUPER,j,focusstack,next
      bind=SUPER,k,focusstack,prev
      bind=SUPER,l,focusdir,right

      # Overview (shows all windows on current tag as a grid)
      bind=SUPER,Tab,toggleoverview,1

      # =====================================================================
      # Key Bindings — Move / Swap Windows
      # =====================================================================
      # exchange_client = swap positions with the window in that direction
      # exchange_stack_client = reorder within the stack (changes tiling order)
      # zoom = swap focused window with master (the big one on the left)
      bind=SUPER+SHIFT,h,exchange_client,left
      bind=SUPER+SHIFT,j,exchange_stack_client,next
      bind=SUPER+SHIFT,k,exchange_stack_client,prev
      bind=SUPER+SHIFT,l,exchange_client,right
      bind=SUPER+SHIFT,Return,zoom,

      # =====================================================================
      # Key Bindings — Tags
      # =====================================================================
      # view = show only this tag (like switching workspace)
      # tag = move focused window to this tag
      # Tags are 0-indexed internally: Super+1 = tag 0, Super+9 = tag 8

      bind=SUPER,1,view,0
      bind=SUPER,2,view,1
      bind=SUPER,3,view,2
      bind=SUPER,4,view,3
      bind=SUPER,5,view,4
      bind=SUPER,6,view,5
      bind=SUPER,7,view,6
      bind=SUPER,8,view,7
      bind=SUPER,9,view,8

      bind=SUPER+SHIFT,1,tag,0
      bind=SUPER+SHIFT,2,tag,1
      bind=SUPER+SHIFT,3,tag,2
      bind=SUPER+SHIFT,4,tag,3
      bind=SUPER+SHIFT,5,tag,4
      bind=SUPER+SHIFT,6,tag,5
      bind=SUPER+SHIFT,7,tag,6
      bind=SUPER+SHIFT,8,tag,7
      bind=SUPER+SHIFT,9,tag,8

      # Navigate to prev/next tag that has windows (_have_client skips empty tags)
      bind=SUPER+CTRL,h,viewtoleft_have_client,
      bind=SUPER+CTRL,l,viewtoright_have_client,

      # =====================================================================
      # Key Bindings — Layouts
      # =====================================================================
      # switch_layout cycles through circle_layout list (tile→scroller→monocle→grid)
      bind=SUPER,n,switch_layout,
      bind=SUPER,t,setlayout,tile
      bind=SUPER,s,setlayout,scroller
      bind=SUPER,w,setlayout,monocle
      bind=SUPER,g,setlayout,grid

      # Master area ratio (tile layout): [ shrinks master, ] grows it
      bind=SUPER,bracketleft,setmfact,-0.05
      bind=SUPER,bracketright,setmfact,+0.05
      # Number of master windows: = adds one, Shift+= removes one
      bind=SUPER,equal,incnmaster,1
      bind=SUPER+SHIFT,equal,incnmaster,-1

      # Gaps: Ctrl+[ / Ctrl+] to adjust, 0 to toggle gaps on/off
      bind=SUPER+CTRL,bracketleft,incgaps,-1
      bind=SUPER+CTRL,bracketright,incgaps,+1
      bind=SUPER,0,togglegaps,

      # Scroller proportions: Shift+[ / Shift+] to adjust window width
      # Ctrl+P cycles through presets (0.5, 0.8, 1.0)
      bind=SUPER+SHIFT,bracketleft,set_proportion,-0.1
      bind=SUPER+SHIFT,bracketright,set_proportion,+0.1
      bind=SUPER+CTRL,p,switch_proportion_preset,

      # =====================================================================
      # Key Bindings — Monitors
      # =====================================================================
      # , (comma) and . (period) = left/right monitor
      bind=SUPER,comma,focusmon,left
      bind=SUPER,period,focusmon,right
      # tagmon = send window to another monitor
      bind=SUPER+SHIFT,comma,tagmon,left
      bind=SUPER+SHIFT,period,tagmon,right

      # =====================================================================
      # Key Bindings — Resize Mode
      # =====================================================================
      # Enter resize mode with Super+Alt+R, then use plain H/J/K/L to resize.
      # Shift+H/J/K/L for big steps. Escape or Enter to exit back to default.

      keymode=resize
      bind=NONE,h,resizewin,-20,0
      bind=NONE,l,resizewin,20,0
      bind=NONE,k,resizewin,0,-20
      bind=NONE,j,resizewin,0,20
      bind=SHIFT,h,resizewin,-100,0
      bind=SHIFT,l,resizewin,100,0
      bind=SHIFT,k,resizewin,0,-100
      bind=SHIFT,j,resizewin,0,100
      bind=NONE,Escape,setkeymode,default
      bind=NONE,Return,setkeymode,default

      keymode=default
      bind=SUPER+ALT,r,setkeymode,resize

      # Direct resize (without entering resize mode)
      bind=SUPER+ALT,h,resizewin,-20,0
      bind=SUPER+ALT,l,resizewin,20,0
      bind=SUPER+ALT,k,resizewin,0,-20
      bind=SUPER+ALT,j,resizewin,0,20
      bind=SUPER+SHIFT+ALT,h,resizewin,-100,0
      bind=SUPER+SHIFT+ALT,l,resizewin,100,0
      bind=SUPER+SHIFT+ALT,k,resizewin,0,-100
      bind=SUPER+SHIFT+ALT,j,resizewin,0,100

      # =====================================================================
      # Key Bindings — Floating Window Movement
      # =====================================================================
      bind=SUPER+CTRL+SHIFT,h,movewin,-50,0
      bind=SUPER+CTRL+SHIFT,l,movewin,50,0
      bind=SUPER+CTRL+SHIFT,k,movewin,0,-50
      bind=SUPER+CTRL+SHIFT,j,movewin,0,50

      # =====================================================================
      # Mouse Bindings
      # =====================================================================
      # Super + drag = move, Super + right-drag = resize
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_right,moveresize,curresize
      mousebind=SUPER,btn_middle,togglemaximizescreen,0

      # =====================================================================
      # Scroll (Axis) Bindings
      # =====================================================================
      # Super + scroll = switch between occupied tags
      # Alt + scroll = cycle focus through windows in stack
      axisbind=SUPER,UP,viewtoleft_have_client,
      axisbind=SUPER,DOWN,viewtoright_have_client,
      axisbind=ALT,UP,focusstack,prev
      axisbind=ALT,DOWN,focusstack,next

      # =====================================================================
      # Trackpad Gestures
      # =====================================================================
      # 3 fingers: navigate windows and overview
      # 4 fingers: navigate tags
      gesturebind=none,left,3,focusdir,left
      gesturebind=none,right,3,focusdir,right
      gesturebind=none,up,3,toggleoverview,1
      gesturebind=none,down,3,toggleoverview,1
      gesturebind=none,left,4,viewtoleft_have_client,
      gesturebind=none,right,4,viewtoright_have_client,

      # =====================================================================
      # Media Keys
      # =====================================================================
      # bindl = "locked" bindings: work even when screen is locked
      bindl=NONE,XF86AudioRaiseVolume,spawn,${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bindl=NONE,XF86AudioLowerVolume,spawn,${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      bindl=NONE,XF86AudioMute,spawn,${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl=NONE,XF86MonBrightnessUp,spawn,${pkgs.brightnessctl}/bin/brightnessctl set +5%
      bindl=NONE,XF86MonBrightnessDown,spawn,${pkgs.brightnessctl}/bin/brightnessctl set 5%-
      bindl=NONE,XF86AudioPlay,spawn,${pkgs.playerctl}/bin/playerctl play-pause
      bindl=NONE,XF86AudioNext,spawn,${pkgs.playerctl}/bin/playerctl next
      bindl=NONE,XF86AudioPrev,spawn,${pkgs.playerctl}/bin/playerctl previous

      # =====================================================================
      # Lid Switch
      # =====================================================================
      # Lock screen when laptop lid is closed
      switchbind=fold,spawn,${lockscreen}
    '';
  };

  # Systemd user service for MangoWC session environment
  systemd.user.services.mango-session-env = {
    Unit = {
      Description = "Set MangoWC session environment variables for Wayland";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "mango-env-setup" ''
        ${pkgs.systemd}/bin/systemctl --user import-environment \
          SSH_AUTH_SOCK \
          WAYLAND_DISPLAY \
          XDG_CURRENT_DESKTOP \
          XDG_SESSION_DESKTOP \
          XDG_SESSION_TYPE \
          NIXOS_OZONE_WL \
          ELECTRON_OZONE_PLATFORM_HINT \
          QT_QPA_PLATFORM \
          GDK_BACKEND \
          MOZ_ENABLE_WAYLAND

        ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
          SSH_AUTH_SOCK \
          WAYLAND_DISPLAY \
          DISPLAY \
          XDG_CURRENT_DESKTOP \
          XDG_SESSION_DESKTOP \
          XDG_SESSION_TYPE \
          GDK_BACKEND \
          NIXOS_OZONE_WL \
          ELECTRON_OZONE_PLATFORM_HINT
      '';
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
