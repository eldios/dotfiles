{ config, lib, pkgs, ... }:

let
  # Access Stylix colors
  colors = config.lib.stylix.colors;
in
{
  services.mako = {
    enable = true;

    # Main settings
    settings = {
      # Appearance
      font = lib.mkDefault "${config.stylix.fonts.sansSerif.name} 11";
      width = 400;
      height = 150;
      margin = "10,20";
      padding = "15";
      border-size = 2;
      border-radius = 8;
      icon-path = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
      max-icon-size = 48;

      # Colors with Stylix integration
      background-color = lib.mkDefault "#${colors.base00}DD"; # Base background with transparency
      text-color = lib.mkDefault "#${colors.base05}FF"; # Base text color
      border-color = lib.mkDefault "#${colors.base0D}FF"; # Accent color for border
      progress-color = lib.mkDefault "over #${colors.base0B}FF"; # Progress bar color

      # Position and behavior
      layer = "overlay"; # Show on top of fullscreen windows
      anchor = "top-right"; # Position in the top-right corner
      default-timeout = 7000; # Default timeout in milliseconds
      ignore-timeout = false; # Respect notification's requested timeout
      max-visible = 5; # Maximum number of visible notifications
      sort = "-time"; # Sort by time, newest first

      # Format
      markup = true; # Enable Pango markup
      actions = true; # Enable actions

      # Grouping
      #group-by = [ "app-name" "category" ]; # Group notifications by app and category

      # Interaction
      on-button-left = "invoke-default-action";
      on-button-middle = "dismiss-all";
      on-button-right = "dismiss";
      on-touch = "dismiss";

      # Critical notifications - red border, longer timeout
      "urgency=critical" = {
        border-color = lib.mkDefault "#${colors.base08}FF";
        default-timeout = lib.mkDefault 10000;
      };

      # Low urgency - more subtle
      "urgency=low" = {
        border-color = lib.mkDefault "#${colors.base03}FF";
        default-timeout = lib.mkDefault 5000;
      };

      # Notifications with images - more space
      "actionable" = {
        border-color = lib.mkDefault "#${colors.base0E}FF";
      };

      # Media player notifications
      "category=mpris" = {
        default-timeout = lib.mkDefault 3000;
      };
    };
  };
}
