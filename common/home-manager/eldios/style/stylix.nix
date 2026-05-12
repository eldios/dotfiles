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

    # Minimal stylix footprint: keep only Firefox theming + centralized
    # fonts (stylix.fonts referenced by other modules). Everything else
    # themed via omarchy current/theme files.
    targets = {
      alacritty.enable = false;
      ghostty.enable = false;
      kitty.enable = false;
      gtk.enable = false;
      rofi.enable = false;
      sway.enable = false;
      wezterm.enable = false;
      hyprland.enable = lib.mkForce false;
      hyprpaper.enable = lib.mkForce false;
      waybar.enable = lib.mkForce false;

      firefox = {
        enable = true;
        profileNames = ["eldios"];
      };
    };
  };
}
