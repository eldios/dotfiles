# GUI programs for desktop/laptop hosts
# Extends base CLI programs with GUI applications
{
  imports = [
    ./common_programs_base.nix

    ./style/stylix.nix

    ./programs/nushell.nix
    ./programs/ssh-agents.nix

    # Terminal emulators
    ./programs/alacritty.nix
    ./programs/ghostty.nix
    ./programs/kitty.nix
    ./programs/niri.nix
    ./programs/rio.nix
    ./programs/rofi.nix
    ./programs/tmux.nix
    ./programs/waveterm.nix
    ./programs/wezterm.nix

    # Browsers and apps
    ./programs/firefox.nix
    ./programs/keybase.nix

    # Packages
    ./programs/packages_common_gui.nix
    ./programs/packages_linux_gui.nix
    ./programs/packages_mailspring.nix
  ];
}

# vim: set ts=2 sw=2 et ai list nu
