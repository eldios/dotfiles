-- Core Hyprland options (port of the hyprlang `settings` tree).

hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OMARCHY_PATH", os.getenv("HOME") .. "/.local/share/omarchy")

hl.config({
  general = {
    layout = "dwindle",
    resize_on_border = true,
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    allow_tearing = false,
    no_focus_fallback = true,
  },

  dwindle = {
    pseudotile = true,
    preserve_split = true,
    force_split = 2,
    use_active_for_splits = true,
    default_split_ratio = 1.0,
  },

  group = {
    groupbar = {
      font_size = 12,
      font_family = "DejaVu Sans Mono",
      font_weight_active = "ultraheavy",
      font_weight_inactive = "normal",
      indicator_height = 0,
      indicator_gap = 5,
      height = 22,
      gaps_in = 5,
      gaps_out = 0,
      gradients = true,
      gradient_rounding = 0,
      gradient_round_only_edges = false,
    },
  },

  decoration = {
    rounding = 10,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(00000066)",
    },
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      xray = true,
      contrast = 0.9,
      brightness = 0.8,
    },
    active_opacity = 0.95,
    inactive_opacity = 0.85,
  },

  animations = {
    enabled = true,
  },

  input = {
    follow_mouse = 1,
    kb_layout = "us",
    kb_options = "caps:escape",
    repeat_rate = 40,
    repeat_delay = 250,
    numlock_by_default = true,
    sensitivity = 0.5,
    touchpad = {
      natural_scroll = false,
      disable_while_typing = true,
      drag_lock = true,
      scroll_factor = 0.4,
      clickfinger_behavior = true,
    },
  },

  misc = {
    animate_manual_resizes = true,
    animate_mouse_windowdragging = true,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    disable_scale_notification = true,
    enable_swallow = true,
    focus_on_activate = true,
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = true,
    allow_session_lock_restore = true,
    anr_missed_pings = 3,
    vfr = true,
  },

  cursor = {
    hide_on_key_press = true,
    warp_on_change_workspace = 1,
  },

  binds = {
    allow_workspace_cycles = true,
    workspace_back_and_forth = true,
    hide_special_on_workspace_change = true,
  },

  debug = {
    suppress_errors = true,
  },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 4, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "easeOutQuint", style = "slidevert" })
