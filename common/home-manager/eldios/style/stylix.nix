# common/home-manager/eldios/style/stylix.nix
{
  lib,
  pkgs,
  ...
}: {
  stylix = {
    enable = true;
    autoEnable = true;
    # Disable overlays to avoid warning with home-manager.useGlobalPkgs
    overlays.enable = false;

    image = ../../../themes/wp.png;
    polarity = "dark";

    # Add base16 scheme if theme file doesn't exist
    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # https://nix-community.github.io/stylix/options/platforms/nixos.html
    targets = {
      alacritty.enable = true;
      ghostty.enable = true;
      gtk.enable = true;
      hyprland.enable = lib.mkForce false;
      hyprpaper.enable = lib.mkForce false; # let variety + swww manage wallpapers
      kitty.enable = true;
      rofi.enable = true;
      sway.enable = true;
      waybar.enable = lib.mkForce false;
      wezterm.enable = true;

      firefox = {
        enable = true;
        profileNames = ["eldios"];
      };
    };
  };
}
