{ ... }:
{
  programs = {
    home-manager = {
      # set home-manager to handle itself
      enable = true;
    };
  }; # EOM programs

  home = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    username = "eldios";
    homeDirectory = "/home/eldios";

    file = { };

    sessionVariables = {
      # Hardware-specific (AMD GPU)
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";

      # Terminal
      TERM = "xterm-256color";

      # NOTE: WM-specific vars (GDK_BACKEND, QT_QPA_PLATFORM, NIXOS_OZONE_WL,
      # MOZ_ENABLE_WAYLAND, WLR_NO_HARDWARE_CURSORS) are set per-WM in:
      # - hyprland.nix (Wayland)
      # - i3.nix (X11)
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
