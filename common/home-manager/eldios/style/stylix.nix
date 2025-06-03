# common/home-manager/eldios/style/stylix.nix
{ config, lib, pkgs, ... }:

let
  # Assuming this stylix.nix is in common/home-manager/eldios/style/
  # and themes are in common/themes/
  themesBaseDir = ../../../themes; # Relative path to the 'themes' directory
  themeName = "eldios_neon";

  currentThemePath = themesBaseDir + ("/" + themeName);

  themeFile = currentThemePath + ("/" + themeName) + ".yaml";
in
{
  stylix = {
    enable = true; # Enable stylix for this home-manager user
    autoEnable = true; # We will explicitly define targets

    image = "${ themesBaseDir }/wp.jpg";
    polarity = "dark";

    targets = {
      # Explicitly enable targets based on previous setup
      alacritty.enable = true; # Will be themed manually using Stylix vars
      gtk.enable = true;
      ghostty.enable = true;
      hyprland.enable = true; # Stylix can still manage some hyprland vars
      kitty.enable = true;
      rofi.enable = true;
      waybar.enable = true; # Will be themed manually using Stylix vars
      wezterm.enable = true; # If still used and Stylix supports it well
      firefox = {
        enable = true;
        profileNames = [ "eldios" ];
      };
    };
  };
}
