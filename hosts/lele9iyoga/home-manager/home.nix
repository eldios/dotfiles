{ ... }:
{
  nixpkgs.config.allowUnfree = true;

  programs = {
    home-manager = { # set home-manager to handle itself
      enable = true;
    };
  }; # EOM programs

  xdg.desktopEntries = {
    portmaster = {
      name = "Portmaster";
      exec = "/opt/safing/portmaster/portmaster-start app --data=/opt/safing/portmaster";
      terminal = false;
      categories = [ "Application" "System" ];
      genericName = "Portmaster";
    };
  };

  home = {
    stateVersion = "24.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

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
  ];

} # EOF

# vim: set ts=2 sw=2 et ai list nu
