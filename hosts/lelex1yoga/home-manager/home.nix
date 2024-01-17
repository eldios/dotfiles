{ pkgs, ... }:
{

  home = {
    stateVersion = "24.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    file = { };

    sessionVariables = {
      TERM = "xterm-256color";
    };

    imports = [
      ./pkgs.nix
    ];
  }; # EOM home

  imports = [
    ./display.nix
    ./services.nix
    ./programs.nix
  ];

} # EOF

# vim: set ts=2 sw=2 et ai list nu
