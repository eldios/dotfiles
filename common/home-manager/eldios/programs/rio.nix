# common/home-manager/eldios/programs/rio.nix
{ config, lib, pkgs, ... }:

{
  programs = {
    rio = {
      enable = true;

      # Rio terminal settings
      settings = {
        # INFO: Rio colors are managed by Stylix.
        # No hardcoded color settings here as they will be managed by Stylix

        # Window settings
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          decorations = "Disabled";
          startup_mode = "Maximized";
          background-opacity = 0.95;
        };

        # Font settings - will use system font from Stylix
        font = {
          normal = {
            family = config.stylix.fonts.monospace.name;
            style = "Regular";
          };
          bold = {
            family = config.stylix.fonts.monospace.name;
            style = "Bold";
          };
          italic = {
            family = config.stylix.fonts.monospace.name;
            style = "Italic";
          };
          size = config.stylix.fonts.sizes.terminal;

          # Enable ligatures
          features = {
            calt = true;
            liga = true;
          };
        };

        # Cursor settings
        cursor = {
          style = {
            shape = "Block";
            blinking = true;
          };
          blink_interval = 750;
          unfocused_hollow = true;
        };

        # Scrolling
        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        # Performance settings
        renderer = {
          performance = "High";
          backend = "Automatic";
        };

        # Shell integration
        shell_integration = true;

        # Keyboard bindings
        keyboard = {
          bindings = [
            {
              key = "C";
              mods = "Control|Shift";
              action = "Copy";
            }
            {
              key = "V";
              mods = "Control|Shift";
              action = "Paste";
            }
            {
              key = "PageUp";
              action = "ScrollPageUp";
            }
            {
              key = "PageDown";
              action = "ScrollPageDown";
            }
            {
              key = "Home";
              action = "ScrollToTop";
            }
            {
              key = "End";
              action = "ScrollToBottom";
            }
          ];
        };
      };
    };
  };
}
