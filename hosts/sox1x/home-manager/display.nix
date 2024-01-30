{ config, pkgs, ...}:

{
  imports = [
    ./programs/sway.nix
    ./programs/hyprland.nix
    ./programs/waybar.nix
  ];



  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };


  home = {
    pointerCursor = {
      gtk.enable = true;
      # cursor theme
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
    };
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
