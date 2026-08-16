-- Startup commands (port of the hyprlang exec-once list).

local bin = "/etc/profiles/per-user/eldios/bin/"

o.exec_on_start("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP GDK_BACKEND NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT")

-- Which shell owns the screen is a runtime choice: desktop-switch starts the
-- one chosen last and falls back to a working stack if it cannot.
o.exec_on_start(bin .. "desktop-switch \"$(cat \"${XDG_STATE_HOME:-$HOME/.local/state}/desktop-stack\" 2>/dev/null || echo classic)\"")

o.exec_on_start("sleep 1 && " .. bin .. "omarchy-theme-bg-set \"${XDG_STATE_HOME:-$HOME/.local/state}/riso/current/background\"")
o.exec_on_start("wl-clip-persist --clipboard regular")
o.exec_on_start("wl-paste --watch cliphist store")
