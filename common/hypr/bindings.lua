-- Keybindings. Modifier grammar:
--   SUPER              direct action: launchers, focus, workspace, window toggles
--   SUPER SHIFT        move/strong variant of the bare action (or its inverse)
--   SUPER CTRL         window groups + secondary apps
--   SUPER CTRL SHIFT   inverse/exit of the CTRL action
--   SUPER ALT          hold-to-repeat resize (+SHIFT: workspace to monitor)
-- Known exceptions: the F family (F files, SHIFT+F fullscreen, CTRL+F client
-- fullscreen), screenshots on SHIFT+S/A, Print = color picker.

local bin = "/etc/profiles/per-user/eldios/bin/"

-- Anything a desktop shell answers goes through shell-dispatch, which asks
-- whichever one is running. Naming a shell's own command here would tie these
-- keys to it, and desktop-switch can change it at any time.
local ask = bin .. "shell-dispatch "

-- Session / power
o.bind("SUPER + CTRL + SHIFT + Q", "Power menu", "wlogout")
o.bind("SUPER + CTRL + Q", "Lock screen", "hyprlock")

-- WM launchers
o.bind("SUPER + D", "App menu", ask .. "launcher")
o.bind("SUPER + SHIFT + D", "Runner", ask .. "menu")
o.bind("SUPER + F", "Files", "ghostty -e yazi")
o.bind("SUPER + E", "Emoji / symbols", ask .. "emoji")
o.bind("SUPER + W", "Window menu", ask .. "menu")
o.bind("SUPER + M", "Main menu", ask .. "menu")
-- Theming is riso's job on every stack, so these keys skip shell-dispatch
-- and call it directly: same picker whichever shell owns the screen.
o.bind("SUPER + SHIFT + T", "Theme picker", bin .. "riso-carousel")
o.bind("SUPER + SHIFT + B", "Background picker", bin .. "riso-carousel backgrounds")

-- Applications
o.bind("SUPER + RETURN", "Terminal", "ghostty")
o.bind("SUPER + CTRL + M", "Mail", "mailspring")
o.bind("SUPER + CTRL + A", "Audio mixer", "pavucontrol")
o.bind("SUPER + CTRL + B", "Bluetooth", "blueman-manager")
o.bind("SUPER + CTRL + T", "System monitor", "ghostty -e btop")

-- Window state
o.bind("SUPER + SHIFT + C", "Close window", hl.dsp.window.close())
o.bind("SUPER + SHIFT + SPACE", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + SHIFT + F", "Fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
o.bind("SUPER + CTRL + F", "Client-only fullscreen", hl.dsp.window.fullscreen_state({ internal = 0, client = 2 }))
o.bind("SUPER + T", "Pin floating window", hl.dsp.window.pin())
o.bind("SUPER + C", "Center floating window", hl.dsp.window.center())
o.bind("SUPER + B", "Toggle window transparency", "omarchy-hyprland-window-transparency-toggle")

-- Dwindle and window order
o.bind("SUPER + P", "Pseudo-tile", hl.dsp.window.pseudo())
o.bind("SUPER + X", "Toggle split direction", hl.dsp.layout("togglesplit"))
o.bind("SUPER + I", "Cycle focus forward", hl.dsp.window.cycle_next())
o.bind("SUPER + O", "Cycle focus backward", hl.dsp.window.cycle_next({ next = false }))
o.bind("SUPER + SHIFT + I", "Swap with next window", hl.dsp.window.swap({ next = true }))
o.bind("SUPER + SHIFT + O", "Swap with previous window", hl.dsp.window.swap({ prev = true }))

-- Focus and movement
o.bind("SUPER + TAB", "Focus next monitor", hl.dsp.focus({ monitor = "+1" }))
o.bind("SUPER + SHIFT + TAB", "Focus previous monitor", hl.dsp.focus({ monitor = "-1" }))
for key, dir in pairs({ H = "l", J = "d", K = "u", L = "r" }) do
  o.bind("SUPER + " .. key, "Focus " .. dir, hl.dsp.focus({ direction = dir }))
  o.bind("SUPER + SHIFT + " .. key, "Move window " .. dir, hl.dsp.window.move({ direction = dir }))
  o.bind("SUPER + CTRL + " .. key, "Move into group " .. dir, hl.dsp.window.move({ into_group = dir }))
  -- out_of_group takes no direction: four deliberate aliases mirroring entry
  o.bind("SUPER + CTRL + SHIFT + " .. key, "Move out of group", hl.dsp.window.move({ out_of_group = true }))
end
o.bind("SUPER + Z", "Focus urgent window", hl.dsp.focus({ urgent_or_last = true }))

-- Workspaces and scratchpad
for ws = 1, 10 do
  local key = tostring(ws % 10)
  o.bind("SUPER + " .. key, "Workspace " .. ws, hl.dsp.focus({ workspace = tostring(ws) }))
  o.bind("SUPER + SHIFT + " .. key, "Move to workspace " .. ws, hl.dsp.window.move({ workspace = tostring(ws), follow = false }))
end
o.bind("SUPER + MINUS", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
o.bind("SUPER + SHIFT + MINUS", "Move to scratchpad", hl.dsp.window.move({ workspace = "special:scratchpad" }))
o.bind("SUPER + BACKSPACE", "Previous workspace", hl.dsp.focus({ workspace = "previous" }))
for key, dir in pairs({ LEFT = "l", RIGHT = "r", UP = "u", DOWN = "d" }) do
  o.bind("SUPER + SHIFT + ALT + " .. key, "Move workspace to monitor " .. dir, hl.dsp.workspace.move({ monitor = dir }))
end

-- Screenshots and clipboard
o.bind("SUPER + SHIFT + S", "Screenshot area", "grimblast copy area")
o.bind("SUPER + SHIFT + A", "Screenshot screen", "grimblast copysave screen ~/Pictures/Screenshots/$(date +%F_%T).png")
o.bind("SUPER + PRINT", "Color picker", "sh -c 'pkill hyprpicker || hyprpicker -a'")
o.bind("SUPER + V", "Clipboard history", ask .. "clipboard")
o.bind("SUPER + SHIFT + V", "Save clipboard to file", bin .. "clip-save")

-- Notifications
o.bind("SUPER + N", "Notifications", ask .. "notifications")
o.bind("SUPER + SHIFT + N", "Notification history", bin .. "notif-history")

-- Window groups
o.bind("SUPER + G", "Toggle group", hl.dsp.group.toggle())
o.bind("SUPER + CTRL + G", "Lock group", hl.dsp.group.lock_active({ action = "toggle" }))
o.bind("SUPER + CTRL + TAB", "Next tab in group", hl.dsp.group.next())
o.bind("SUPER + CTRL + SHIFT + TAB", "Previous tab in group", hl.dsp.group.prev())

-- Hyprland maintenance
o.bind("SUPER + SHIFT + R", "Force renderer reload", hl.dsp.force_renderer_reload())
o.bind("SUPER + CTRL + SHIFT + R", "Reload configuration", "hyprctl reload")

-- Media and hardware (locked = also active on the lockscreen)
o.bind("XF86AudioRaiseVolume", "Volume up", "swayosd-client --output-volume raise", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "swayosd-client --output-volume lower", { locked = true, repeating = true })
o.bind("XF86MonBrightnessUp", "Brightness up", "swayosd-client --brightness raise", { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", "swayosd-client --brightness lower", { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "swayosd-client --output-volume mute-toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "swayosd-client --input-volume mute-toggle", { locked = true })
o.bind("XF86AudioPlay", "Play/pause", "playerctl play-pause", { locked = true })
o.bind("XF86AudioNext", "Next track", "playerctl next", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "playerctl previous", { locked = true })

-- Window resize (hold to repeat)
for key, delta in pairs({ H = { -20, 0 }, L = { 20, 0 }, K = { 0, -20 }, J = { 0, 20 } }) do
  o.bind("SUPER + ALT + " .. key, "Resize window", hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true }), { repeating = true })
  o.bind("SUPER + SHIFT + ALT + " .. key, "Resize window (large)", hl.dsp.window.resize({ x = delta[1] * 5, y = delta[2] * 5, relative = true }), { repeating = true })
end

-- Mouse
o.bind("SUPER + mouse:272", "Move window", hl.dsp.window.drag(), { mouse = true })
o.bind("SUPER + mouse:273", "Resize window", hl.dsp.window.resize(), { mouse = true })
