# FIXME: Cursor, GTK and Qt theming are now primarily managed by Stylix.
{ pkgs, ...}:
{
  imports = [
    ../../../common/home-manager/eldios/programs/mako.nix
    ../../../common/home-manager/eldios/programs/sway.nix
    ../../../common/home-manager/eldios/programs/hyprland.nix
    ../../../common/home-manager/eldios/programs/waybar.nix
  ];

  # gtk = {
  #   enable = true;
  #   theme = {
  #     name = "Adwaita-dark";
  #     package = pkgs.gnome-themes-extra;
  #   };
  # };

  # qt = {
  #   enable = true;
  #   platformTheme = {
  #       name = "gtk";
  #   };
  #   style = {
  #     name = "adwaita-dark";
  #     package = pkgs.adwaita-qt;
  #   };
  # };


  home = {
    # pointerCursor = {
    #   gtk.enable = true;
    #   # cursor theme
    #   package = pkgs.bibata-cursors;
    #   name = "Bibata-Modern-Ice";
    #   size = 22;
    # };
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
