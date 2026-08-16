-- Personal keybinding overrides.
--
-- Omarchy's defaults load first and cover 179 bindings; only what differs
-- belongs here. Rebinding a default key replaces it.
--
-- Anything that asks the shell for something goes through shell-dispatch,
-- which translates the action for whichever shell is running. Without that
-- these keys would be dead the moment desktop-switch changes stack, since
-- each shell has its own command for the same thing.

local bin = "/etc/profiles/per-user/eldios/bin/"
local ask = "shell-dispatch "

-- Menus and launchers. Omarchy puts these on SPACE; these hands know D and M.
o.bind("SUPER + D", "App menu", ask .. "launcher")
o.bind("SUPER + SHIFT + D", "Runner", ask .. "menu")
o.bind("SUPER + M", "Main menu", ask .. "menu")
o.bind("SUPER + E", "Emoji / symbols", ask .. "emoji")

-- The defaults bind these to Omarchy's own commands, which answer to nobody
-- once another shell owns the screen.
o.bind("SUPER + SPACE", "Main menu", ask .. "menu")
o.bind("SUPER + ALT + SPACE", "App menu", ask .. "launcher")
o.bind("SUPER + CTRL + V", "Clipboard", ask .. "clipboard")
o.bind("SUPER + CTRL + E", "Emoji", ask .. "emoji")
o.bind("SUPER + CTRL + A", "Audio panel", ask .. "audio")
o.bind("SUPER + CTRL + B", "Bluetooth panel", ask .. "bluetooth")
o.bind("SUPER + CTRL + W", "Network panel", ask .. "network")
o.bind("SUPER + CTRL + L", "Lock", ask .. "lock")

-- Applications
o.bind("SUPER + CTRL + M", "Mail", "mailspring")
o.bind("SUPER + CTRL + T", "System monitor", "ghostty -e btop")

-- Window state
o.bind("SUPER + SHIFT + SPACE", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + B", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")

-- Focus order
o.bind("SUPER + I", "Cycle focus forward", hl.dsp.window.cycle_next())
o.bind("SUPER + O", "Cycle focus backward", hl.dsp.window.cycle_next({ next = false }))
o.bind("SUPER + SHIFT + I", "Swap with next window", hl.dsp.window.swap({ next = true }))
o.bind("SUPER + SHIFT + O", "Swap with previous window", hl.dsp.window.swap({ prev = true }))
o.bind("SUPER + Z", "Focus urgent window", hl.dsp.focus({ urgent_or_last = true }))

-- Scratchpad
o.bind("SUPER + MINUS", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + SHIFT + MINUS", "Move to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad" }))

-- Window groups
o.bind("SUPER + CTRL + G", "Lock group", hl.dsp.group.lock_active({ action = "toggle" }))
o.bind("SUPER + CTRL + SHIFT + TAB", "Previous tab in group", hl.dsp.group.prev())
for key, dir in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
  o.bind("SUPER + CTRL + " .. key, "Move into group " .. dir, hl.dsp.window.move({ into_group = dir }))
  -- out_of_group takes no direction: four deliberate aliases mirroring entry
  o.bind("SUPER + CTRL + SHIFT + " .. key, "Move out of group", hl.dsp.window.move({ out_of_group = true }))
end

-- Notifications
o.bind("SUPER + N", "Restore last notifications", "omarchy-shell shell call omarchy.notifications replay")

-- Clipboard. Picks an entry, then saves it through a GTK file dialog.
o.bind("SUPER + SHIFT + V", "Save clipboard to file", bin .. "clip-save")

-- Session
o.bind("SUPER + CTRL + SHIFT + Q", "Power menu", "omarchy-menu toggle system")
o.bind("SUPER + SHIFT + R", "Force renderer reload", hl.dsp.force_renderer_reload())
o.bind("SUPER + CTRL + SHIFT + R", "Reload configuration", "hyprctl reload")

-- Window resize (hold to repeat)
for key, delta in pairs({ H = { -20, 0 }, L = { 20, 0 }, K = { 0, -20 }, J = { 0, 20 } }) do
  o.bind("SUPER + ALT + " .. key, "Resize window", hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true }), { repeating = true })
end
