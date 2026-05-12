{ config, ... }:
{
  programs = {

    alacritty = {
      enable = true;

      settings = {
        # Colors imported from the current omarchy theme. Updated atomically
        # by `omarchy-theme-set` on every switch; alacritty live-reloads.
        general = {
          live_config_reload = true;
          import = [
            "${config.home.homeDirectory}/.config/omarchy/current/theme/alacritty.toml"
          ];
        };

        window = {
          padding.x = 0;
          padding.y = 10;
          class.instance = "Alacritty";
          class.general = "Alacritty";
          decorations = "None";
        };

        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        cursor = {
          style = {
            shape = "Block";
            blinking = "On";
          };

          blink_interval = 750;
        };

        keyboard.bindings = [
          {
            key = "C";
            mods = "Shift|Control";
            action = "Copy";
          }
          {
            key = "V";
            mods = "Shift|Control";
            action = "Paste";
          }
          {
            key = "PageUp";
            mode = "~Alt";
            action = "ScrollPageUp";
          }
          {
            key = "PageDown";
            mode = "~Alt";
            action = "ScrollPageDown";
          }
        ];

      }; # EOM settings
    }; # EOM alacritty
  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
