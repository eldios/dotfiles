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

  # L13 Yoga Gen 3 - 1920x1200 display, no HiDPI scaling needed
  wayland.windowManager.hyprland.settings.monitor = [
    ", preferred, auto, 1"
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
