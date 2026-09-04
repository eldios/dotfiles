-- Window rules (port of the hyprlang windowrule blocks in extraConfig).

o.window("^(org\\.omarchy\\.terminal)$", { float = true, size = { 1120, 720 }, center = true })
o.window("^(lxqt-openssh-askpass|ssh-askpass)$", { float = true, size = { 400, 150 }, center = true })
hl.window_rule({ match = { title = "^(OpenSSH)(.*)$" }, float = true, size = { 400, 150 }, center = true })

for _, title in ipairs({
  "^(pavucontrol)$",
  "^(nm-connection-editor)$",
  "^(org\\.gnome\\.Calculator)$",
  "^(org\\.gnome\\.Nautilus)$",
  "^(org\\.gnome\\.Settings)$",
}) do
  hl.window_rule({ match = { title = title }, float = true })
end

hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, pin = true })
o.window("^(screenkey)$", { float = true, border_size = 0 })

for _, class in ipairs({
  "^(blueman-manager)$",
  "^(thunar)$",
  "^(pcmanfm)$",
  "^(org\\.gnome\\.FileRoller)$",
  "^(xdg-desktop-portal-gtk)$",
}) do
  o.window(class, { float = true })
end

-- Strip every decoration effect from fullscreen windows. Re-evaluates on
-- every fullscreen state change.
hl.window_rule({
  match = { fullscreen = 1 },
  no_blur = 1,
  no_dim = 1,
  no_shadow = 1,
  rounding = 0,
  opaque = 1,
})
