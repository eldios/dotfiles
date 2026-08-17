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

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
