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

  # L13 Yoga Gen 3 - 1920x1200 display, no HiDPI scaling needed
  wayland.windowManager.hyprland.settings.monitor = [
    ", preferred, auto, 1"
  ];

  # Barcelo iGPU (Radeon 660M) struggles with heavy compositor effects on
  # battery. Disable blur, drop opacity, lighten rounding. Common config
  # in common/home-manager/eldios/programs/hyprland.nix is tuned for
  # discrete-GPU desktops; lib.mkForce overrides those values here.
  wayland.windowManager.hyprland.settings.decoration = lib.mkForce {
    rounding = 4;
    blur.enabled = false;
    active_opacity = 1.0;
    inactive_opacity = 1.0;
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
