{ lib, ... }:
{
  imports = [
    ../../../common/home-manager/eldios/programs/eww.nix
    ../../../common/home-manager/eldios/programs/hyprland.nix
    ../../../common/home-manager/eldios/programs/i3.nix
    ../../../common/home-manager/eldios/programs/mako.nix
    ../../../common/home-manager/eldios/programs/mango.nix
    ../../../common/home-manager/eldios/programs/sway.nix
    ../../../common/home-manager/eldios/programs/walker.nix
    ../../../common/home-manager/eldios/programs/variety.nix
    ../../../common/home-manager/eldios/programs/waybar.nix

    ../../../common/home-manager/eldios/programs/wayfire.nix
  ];

  # Hyprland is the primary session on this host; picom (X11 compositor)
  # pulled in by i3.nix loops on restart ("Another composite manager is
  # already running") because Hyprland owns the composite selection.
  # Re-enable (mkForce true) if you actually boot into i3 here.
  services.picom.enable = lib.mkForce false;

  # HiDPI scaling for Hyprland on Yoga 9i (2880x1800, 14").
  # Hyprland: higher scale = larger UI. 2 felt too small, 2.5 makes
  # everything ~25% bigger without touching font sizes.
  wayland.windowManager.hyprland.settings.monitor = [
    ", preferred, auto, 2.5"
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
