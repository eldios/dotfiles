# Base CLI programs shared across all hosts (servers, desktops, laptops)
# This module provides the minimal set of programs needed on any system
{
  imports = [
    ./services.nix
    ./sops.nix

    ./programs/neovim.nix
    ./programs/mcp-servers.nix
    ./programs/zellij.nix

    ./programs/zsh.nix
    ./programs/atuin.nix

    ./programs/ssh.nix

    ./programs/git.nix

    ./programs/var.nix

    ./programs/packages_common_cli.nix
    ./programs/packages_linux_cli.nix
  ];
}

# vim: set ts=2 sw=2 et ai list nu
