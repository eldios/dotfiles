{config, ...}: {
  programs = {
    alacritty = {
      enable = true;

      settings = {
        # Colors imported from the theme riso renders; alacritty
        # live-reloads on every switch.
        general = {
          live_config_reload = true;
          # The theme fragment, then the user's own override, which wins.
          # The override is a real file with a stable inode: the theme tree
          # is replaced whole on every switch, which kills the watcher on the
          # fragment, and touching this file is what makes live windows
          # re-read the chain and re-arm it.
          import = [
            "${config.home.homeDirectory}/.local/state/riso/current/theme/alacritty.toml"
            "${config.home.homeDirectory}/.config/riso/overrides/alacritty.toml"
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
}
# EOF
# vim: set ts=2 sw=2 et ai list nu

