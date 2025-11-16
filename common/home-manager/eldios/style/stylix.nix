# common/home-manager/eldios/style/stylix.nix
{ lib, pkgs, ... }:

let
  # Assuming this stylix.nix is in common/home-manager/eldios/style/
  # and themes are in common/themes/
  themesBaseDir = ../../../themes; # Relative path to the 'themes' directory
in
{
  stylix = {
    enable = true;
    autoEnable = true;

    image = "${themesBaseDir}/wp.jpg";
    polarity = "dark";

    # Add base16 scheme if theme file doesn't exist
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # https://nix-community.github.io/stylix/options/platforms/nixos.html
    targets = {
      alacritty.enable = true;
      ghostty.enable = true;
      gtk.enable = true;
      hyprland.enable = true;
      kitty.enable = true;
      rofi.enable = true;
      sway.enable = true;
      waybar.enable = true;
      wezterm.enable = true;

      firefox = {
        enable = true;
        profileNames = [ "eldios" ];
      };
    };
  };
}
