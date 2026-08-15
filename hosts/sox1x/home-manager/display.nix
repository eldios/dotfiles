{
  imports = [
    # Pre-Quickshell desktop: Waybar, Walker, Mako, SwayOSD.
    ../../../common/home-manager/eldios/programs/hyprland.nix
    ../../../common/home-manager/eldios/programs/hyprlock.nix
    ../../../common/home-manager/eldios/programs/mako.nix
    ../../../common/home-manager/eldios/programs/omarchy.nix
    ../../../common/home-manager/eldios/programs/omarchy-runtime.nix
    ../../../common/home-manager/eldios/programs/walker.nix
    ../../../common/home-manager/eldios/programs/waybar.nix
    ../../../common/home-manager/eldios/services/swayosd.nix
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
