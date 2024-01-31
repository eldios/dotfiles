{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "23.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    username = "eldios";

    file = { };

    sessionVariables = {
      TERM = "xterm-256color";
    };
  }; # EOM home

  imports = [
    ./pkgs.nix
    ./display.nix
    ./services.nix
    ./programs.nix
  ];

} # EOF

# vim: set ts=2 sw=2 et ai list nu
