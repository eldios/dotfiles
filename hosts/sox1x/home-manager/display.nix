{ config, pkgs, ...}:
let
  #repo_dir            = "${config.home.homeDirectory}/.dotfiles";
  repo_dir            = "/home/eldios/.dotfiles";
  common_mods_dir     = "${repo_dir}/common";
  common_hm_dir       = "${common_mods_dir}/home-manager/eldios";
  common_programs_dir = "${common_hm_dir}/programs";
in
{
    "${common_programs_dir}/mako.nix"
    "${common_programs_dir}/sway.nix"
    "${common_programs_dir}/hyprland.nix"
    "${common_programs_dir}/waybar.nix"

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
