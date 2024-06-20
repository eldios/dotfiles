{ pkgs, ... }:
{
  xsession.windowManager.i3 = {
    enable = true;

    package = pkgs.i3-gaps;

    config = {
      modifier = "Mod4";
      gaps = {
        inner = 5;
        outer = 5;

        smartBorders = "on";
        smartGaps = true;
      };

      keybindings = {
        "Mod4+1" = "workspace number 1";
        "Mod4+2" = "workspace number 2";
        "Mod4+3" = "workspace number 3";
        "Mod4+4" = "workspace number 4";
        "Mod4+5" = "workspace number 5";
        "Mod4+6" = "workspace number 6";
        "Mod4+7" = "workspace number 7";
        "Mod4+8" = "workspace number 8";
        "Mod4+9" = "workspace number 9";
        "Mod4+0" = "workspace number 10";

        "Mod4+j" = "focus down";
        "Mod4+h" = "focus left";
        "Mod4+l" = "focus right";
        "Mod4+k" = "focus up";
        "Mod4+a" = "focus parent";

        "Mod4+Shift+j" = "move down";
        "Mod4+Shift+h" = "move left";
        "Mod4+Shift+l" = "move right";
        "Mod4+Shift+k" = "move up";

        "Mod4+Return" = " exec kitty";

        "Mod4+Shift+0" = "move container to workspace number 10";
        "Mod4+Shift+1" = "move container to workspace number 1";
        "Mod4+Shift+2" = "move container to workspace number 2";
        "Mod4+Shift+3" = "move container to workspace number 3";
        "Mod4+Shift+4" = "move container to workspace number 4";
        "Mod4+Shift+5" = "move container to workspace number 5";
        "Mod4+Shift+6" = "move container to workspace number 6";
        "Mod4+Shift+7" = "move container to workspace number 7";
        "Mod4+Shift+8" = "move container to workspace number 8";
        "Mod4+Shift+9" = "move container to workspace number 9";

        "Mod4+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

        "Mod4+Shift+space" = "floating toggle";
        "Mod4+space" = " focus mode_toggle";
        "Mod4+f" = " fullscreen toggle";

        "Mod4+Shift+minus" = "move scratchpad";
        "Mod4+minus" = " scratchpad show";

        "Mod4+Shift+c" = "kill";
        "Mod4+Shift+Ctrl+r" = "restart";
        "Mod4+Shift+r" = "reload";

        "Mod4+r" = " mode resize";

        "Mod4+d" = " exec /nix/store/afz4sgd6aggjyinp1d7fpyxphpy51d2p-dmenu-5.2/bin/dmenu_run";

        "Mod4+e" = " layout toggle split";
        "Mod4+w" = " layout tabbed";
        "Mod4+s" = " layout stacking";
        "Mod4+v" = " split v";
        "Mod4+Shift+v" = " split h";
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu

