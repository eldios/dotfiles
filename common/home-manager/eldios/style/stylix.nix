# common/home-manager/eldios/style/stylix.nix
{ config, lib, pkgs, inputs, ... }:

let
  # Assuming this stylix.nix is in common/home-manager/eldios/style/
  # and themes are in common/themes/
  themesBaseDir = ../../../themes; # Relative path to the 'themes' directory
  themeName = "eldios_neon";

  currentThemePath = themesBaseDir + ("/" + themeName);

  themeFile = currentThemePath + ("/" + themeName) + ".yaml";
  themePolarityFile = currentThemePath + "/polarity.txt";

  # Read theme data, with fallbacks for robustness (though files should exist)
  themePolarity = lib.removeSuffix "\n" (builtins.readFile themePolarityFile);

in
{
  imports = [ inputs.stylix.homeModules.stylix ];

  # Write the current theme name to a file for scripts or other components to reference
  home.file.".currenttheme".text = themeName;

  stylix = {
    enable = true; # Enable stylix for this home-manager user
    autoEnable = false; # We will explicitly define targets

    base16Scheme = themeFile; # Path to the selected theme's YAML file
    polarity = themePolarity; # "dark" or "light"

    fonts = {
      monospace = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; }; # Keep existing default
      sansSerif = pkgs.lib.mkDefault pkgs.dejavu_fonts;
      serif = pkgs.lib.mkDefault pkgs.dejavu_fonts;
      emoji = pkgs.noto-fonts-emoji;
      sizes = {
        applications = 10;
        desktop = 10;
        terminal = 11;
        monospace = 10;
      };
    };

    cursor = {
      # From previous setup
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    targets = {
      # Explicitly enable targets based on previous setup
      gtk.enable = true;
      qt.enable = true;
      hyprland.enable = true; # Stylix can still manage some hyprland vars
      waybar.enable = false; # Will be themed manually using Stylix vars
      alacritty.enable = false; # Will be themed manually using Stylix vars
      kitty.enable = true;
      wezterm.enable = true; # If still used and Stylix supports it well
      rofi.enable = true;
      cursor.enable = true;
      # Add other targets as needed
    };
  };

  # Manual Alacritty theming using Stylix variables (inspired by librephoenix)
  programs.alacritty.settings.colors = {
    primary.background = "#${config.lib.stylix.colors.base00}";
    primary.foreground = "#${config.lib.stylix.colors.base05}"; # base05 for main text
    cursor.text = "#${config.lib.stylix.colors.base00}";
    cursor.cursor = "#${config.lib.stylix.colors.base05}";
    normal = {
      black = "#${config.lib.stylix.colors.base00}";
      red = "#${config.lib.stylix.colors.base08}";
      green = "#${config.lib.stylix.colors.base0B}";
      yellow = "#${config.lib.stylix.colors.base0A}";
      blue = "#${config.lib.stylix.colors.base0D}";
      magenta = "#${config.lib.stylix.colors.base0E}";
      cyan = "#${config.lib.stylix.colors.base0C}"; # Mapped neon cyan to base0C in YAML
      white = "#${config.lib.stylix.colors.base05}";
    };
    bright = {
      black = "#${config.lib.stylix.colors.base03}";
      red = "#${config.lib.stylix.colors.base08}"; # Often same as normal red or slightly brighter
      green = "#${config.lib.stylix.colors.base0B}";
      yellow = "#${config.lib.stylix.colors.base0A}";
      blue = "#${config.lib.stylix.colors.base0D}";
      magenta = "#${config.lib.stylix.colors.base0E}";
      cyan = "#${config.lib.stylix.colors.base0C}";
      white = "#${config.lib.stylix.colors.base07}";
    };
  };

  # Manual Hyprpaper config using Stylix image
  home.file.".config/hypr/hyprpaper.conf".text = lib.mkIf (config.stylix.image != null) ''
    preload = ${config.stylix.image}
    wallpaper = ,${config.stylix.image}
    # Optionally add splash screen settings if desired
    # splash = true
    # splash_offset = 0.2
    # splash_color = 0x${config.lib.stylix.colors.base00}
  '';
  # Ensure hyprpaper is in packages if used like this:
  # home.packages = [ pkgs.hyprpaper ]; # (already in hyprland.nix's packages)

}
