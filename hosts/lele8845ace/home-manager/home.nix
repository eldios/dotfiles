{ ... }:
{
  programs = {
    home-manager = {
      # set home-manager to handle itself
      enable = true;
    };
  }; # EOM programs

  home = {
    stateVersion = "25.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    username = "eldios";
    homeDirectory = "/home/eldios";

    file = { };

    sessionVariables = {
      GDK_BACKEND = "wayland";
      LIBVA_DRIVER_NAME = "radeonsi";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      TERM = "xterm-256color";
      T_QPA_PLATFORM = "wayland";
      VDPAU_DRIVER = "radeonsi";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  }; # EOM home

  imports = [
    ./display.nix
    ./services.nix

    ./pkgs.nix

    ./common_programs.nix
    ./programs/git.nix
  ];

} # EOF

# vim: set ts=2 sw=2 et ai list nu
