{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs = {
    home-manager = { # set home-manager to handle itself
      enable = true;
    };
  }; # EOM programs

  home = {
    stateVersion = "24.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    username = "eldios";
    homeDirectory = "/home/eldios";

    file = { };

    sessionVariables = {
      TERM = "xterm-256color";
      NIXOS_OZONE_WL = "1";
      LIBVA_DRIVER_NAME = "iHD";
    };
  }; # EOM home

  imports = [
    ./display.nix
    ./services.nix
    ./xremap.nix

    ./pkgs.nix

    ./common_programs.nix
    ./programs/git.nix
    ../../../common/home-manager/eldios/style/stylix.nix # Common Stylix theme and config
    ../../../common/home-manager/eldios/programs/eww.nix   # Eww dashboard/bar
  ];

} # EOF

# vim: set ts=2 sw=2 et ai list nu
