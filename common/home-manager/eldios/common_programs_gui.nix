# GUI programs for desktop/laptop hosts
# Extends base CLI programs with GUI applications
{
  imports = [
    ./common_programs_base.nix

    ./services/audio.nix

    ./programs/nushell.nix
    ./programs/keychain.nix

    # The desktop stack is chosen per host in its display.nix: either
    # omarchy.nix + omarchy-runtime.nix + swayosd.nix (Waybar and Walker), or
    # omarchy-shell.nix (the Omarchy 4 Quickshell desktop). The two are
    # mutually exclusive, so neither is imported here.

    # Terminal emulators
    ./programs/alacritty.nix
    ./programs/ghostty.nix
    ./programs/kitty.nix
    ./programs/rio.nix
    ./programs/tmux.nix
    ./programs/wezterm.nix

    # Apps
    ./programs/keybase.nix

    # Packages
    ./programs/packages_common_gui.nix
    ./programs/packages_linux_gui.nix
  ];

  # Syncthing tray icon (GUI hosts).
  services.syncthing.tray.enable = true;
}
# vim: set ts=2 sw=2 et ai list nu
