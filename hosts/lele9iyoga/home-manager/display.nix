{ lib, pkgs, ... }:
{
  imports = [
    # Every desktop stack is installed and configured; desktop-switch decides
    # at runtime which one owns the screen. omarchy-shell.nix carries the
    # Omarchy 4 Quickshell desktop and DankMaterialShell; waybar, mako and
    # hyprlock keep their own modules so the classic stack stays a desktop
    # rather than a pile of unconfigured binaries.
    ../../../common/home-manager/eldios/programs/hyprland.nix
    ../../../common/home-manager/eldios/programs/omarchy-shell.nix
    ../../../common/home-manager/eldios/programs/waybar.nix
    ../../../common/home-manager/eldios/programs/mako.nix
    ../../../common/home-manager/eldios/programs/hyprlock.nix
  ];

  # Hyprland is the primary session on this host; picom (X11 compositor)
  # pulled in by i3.nix loops on restart ("Another composite manager is
  # already running") because Hyprland owns the composite selection.
  # Re-enable (mkForce true) if you actually boot into i3 here.
  services.picom.enable = lib.mkForce false;

  # HiDPI scaling for Hyprland on Yoga 9i (2880x1800, 14").
  # Hyprland rejected 1.75 (non-integer pixel mapping) and suggested
  # 1.8 - that's what gives a clean transformedSize on this panel.
  desktop.hyprland.monitors = [
    ",preferred,auto,1.8"
  ];

  # Cursor sized for scale 2.5: GTK/Qt/Wayland clients pick up the
  # home-manager pointerCursor; XCURSOR_SIZE covers XWayland apps.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
