-- Extra autostart processes.
--
-- Which shell owns the screen is a runtime choice, not a build-time one:
-- desktop-switch starts the one chosen last, and falls back to a working
-- stack if that one cannot start. Omarchy's own autostart is not used here
-- for the shell, because it would always start Omarchy's.
o.exec_on_start("desktop-switch $(cat ${XDG_STATE_HOME:-$HOME/.local/state}/desktop-stack 2>/dev/null || echo waybar)")

o.launch_on_start("wl-clip-persist --clipboard regular")
o.launch_on_start("wl-paste --watch cliphist store")
