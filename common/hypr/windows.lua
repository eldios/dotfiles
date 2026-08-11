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
