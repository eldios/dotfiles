{pkgs, ...}: {
  # HiDPI scaling for Hyprland on Yoga 9i (2880x1800, 14").
  # Hyprland rejected 1.75 (non-integer pixel mapping) and suggested
  # 1.8 - that's what gives a clean transformedSize on this panel.
  desktop.hyprland.monitors = [
    ",preferred,auto,1.8"
  ];

  # Cursor sized for scale 1.8: GTK/Qt/Wayland clients pick up the
  # home-manager pointerCursor; XCURSOR_SIZE covers XWayland apps.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };
}
# vim: set ts=2 sw=2 et ai list nu

