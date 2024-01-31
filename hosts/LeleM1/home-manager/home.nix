{ pkgs, lib, nixpkgs, nix-colors, ... }:
{
  nixpkgs.config.allowUnfree = true;

  home = {
    stateVersion = "23.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    username = "eldios";
    #homeDirectory = lib.mkForce "/Users/eldios";

    file = { };

    sessionVariables = {
      TERM = "xterm-256color";
    };
  }; # EOM home

  #colorScheme = nix-colors.colorSchemes.gruvbox-dark-soft;

  imports = [
    #nix-colors.homeManagerModules.default
    ./pkgs.nix
    ./programs.nix
    #./apps_workaround.nix
  ];

} # EOF

# vim: set ts=2 sw=2 et ai list nu
