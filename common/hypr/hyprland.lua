-- Hyprland Lua entrypoint. Modules live in ~/.config/hypr/lua/ (deployed by
-- home-manager); omarchy helpers and the current theme come from
-- $OMARCHY_PATH and ~/.config/omarchy. hyprland.conf remains as the
-- fallback: remove this file and reload to roll back to hyprlang.
package.path = (os.getenv("HOME") .. "/.config/?.lua;")
  .. ((os.getenv("OMARCHY_PATH") or (os.getenv("HOME") .. "/.local/share/omarchy")) .. "/?.lua;")
  .. package.path

require("default.hypr.helpers") -- omarchy `o.*` layer on top of `hl.*`

require("hypr.lua.settings")
require("hypr.lua.bindings")
require("hypr.lua.windows")
require("hypr.lua.autostart")

-- Current theme colors, then user overrides (lua ports of the old
-- hyprlang source= includes); both optional.
pcall(require, "omarchy.current.theme.hyprland")
pcall(require, "omarchy.overrides.hypr")
