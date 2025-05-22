{

  programs = {

    alacritty = {
      enable = true;

      settings = {
        # INFO: Alacritty colors are managed by Stylix.
        # No hardcoded 'colors' block was present here. If one were added, it should be commented out.

        general.live_config_reload = true;

        window = {
          padding.x = 0;
          padding.y = 10;
          opacity   = 0.9;
          class.instance = "Alacritty";
          class.general  = "Alacritty";
          decorations = "None";
        };

        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        font = {
          normal = {
            family = "Hack Nerd Font Mono";
            style = "Regular";
          };
          bold = {
            family = "Hack Nerd Font Mono";
            style = "Bold";
          };
          italic = {
            family = "Hack Nerd Font Mono";
            style = "Italic";
          };
          size = 12.0;
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
