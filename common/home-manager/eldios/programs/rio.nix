# common/home-manager/eldios/programs/rio.nix
{ config, lib, pkgs, ... }:
{
  programs = {
    rio = {
      enable = true;

      # Rio terminal settings
      settings = {
        # Colors come from the current omarchy theme via themes/omarchy.toml
        # (symlinked below to current/theme/rio.toml). Rio reloads on config change.
        theme = "omarchy";

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

        # Fonts (colors are themed by omarchy, fonts are not)
        font = {
          normal = {
            family = "DejaVu Sans Mono";
            style = "Regular";
          };
          bold = {
            family = "DejaVu Sans Mono";
            style = "Bold";
          };
          italic = {
            family = "DejaVu Sans Mono";
            style = "Italic";
          };
          size = 12;

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

  # Point rio's "omarchy" theme at the file rendered by omarchy-theme-set.
  # Out-of-store symlink so the runtime theme swap is picked up without a rebuild.
  home.file.".config/rio/themes/omarchy.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/omarchy/current/theme/rio.toml";
}
