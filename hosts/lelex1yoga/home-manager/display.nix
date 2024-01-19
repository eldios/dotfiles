{ config, pkgs, ...}:

{
  imports = [
    ./programs/sway.nix
    ./programs/hyprland.nix
    ./programs/waybar.nix
  ];

  gtk.enable = true;
  qt.enable = false;

  # QT theme
  qt.platformTheme = "gtk";

  # name of gtk theme
  qt.style.name = "adwaita-dark";

  # package to use
  qt.style.package = pkgs.adwaita-qt;

  home = {
    pointerCursor = {
      gtk.enable = true;
      # cursor theme
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
    };
  };

  xdg.portal = {
    enable = true;
    #wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    config.common.default = "*" ;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
