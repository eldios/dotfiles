-- Extra autostart processes.
--
-- The shell, first-run provisioning, power profiles, the monitor watcher and
-- udiskie are started by Omarchy's own autostart, which runs first.

o.launch_on_start("wl-clip-persist --clipboard regular")
o.launch_on_start("wl-paste --watch cliphist store")
