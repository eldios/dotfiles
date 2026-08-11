-- Startup commands (port of the hyprlang exec-once list).

local bin = "/etc/profiles/per-user/eldios/bin/"

o.exec_on_start("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP GDK_BACKEND NIXOS_OZONE_WL ELECTRON_OZONE_PLATFORM_HINT")
o.exec_on_start("waybar")
o.exec_on_start("mako")
o.exec_on_start("sleep 1 && " .. bin .. "omarchy-theme-bg-set \"$HOME/.config/omarchy/current/background\"")
o.exec_on_start("wl-clip-persist --clipboard regular")
o.exec_on_start("wl-paste --watch cliphist store")
