{ ... }:
{
  programs = {
    # set home-manager to handle itself
    home-manager = {
      enable = true;
    };
  }; # EOM programs

  home = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    username = "eldios";
    homeDirectory = "/home/eldios";

    file = { };

    sessionVariables = {
      # Hardware-specific (Intel GPU)
      LIBVA_DRIVER_NAME = "iHD";

      # Terminal
      TERM = "xterm-256color";
    };
  }; # EOM home

  imports = [
    ./display.nix
    ./services.nix
    ./xremap.nix

    ./pkgs.nix

    ./common_programs.nix
    ./programs/git.nix
  ];

} # EOF

# vim: set ts=2 sw=2 et ai list nu
