{ pkgs, ... }:
{

  programs = {
    home-manager = {
      enable = true;
    };
  }; # EOM programs

  imports = [
    ./programs/var.nix
    ./programs/git.nix
    ./programs/neovim.nix
    ./programs/zsh.nix

    ./programs/alacritty.nix
    ./programs/kitty.nix

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
