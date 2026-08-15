{
  imports = [
    # Omarchy 4 desktop: one Quickshell process owns the bar, launcher, menu,
    # notifications, OSDs, panels and lock screen, so Waybar, Walker, Mako,
    # SwayOSD and hyprlock are not imported here.
    ../../../common/home-manager/eldios/programs/hyprland.nix
    ../../../common/home-manager/eldios/programs/omarchy-shell.nix
    ./hyprland-monitors.nix
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  }; # EOF
}
# vim: set ts=2 sw=2 et ai list nu
