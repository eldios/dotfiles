{ config, ... }:

{

  programs.zellij = {
    enable = true;

    enableZshIntegration = false;

    settings = {
      keybindings = {
        locked = {
          "C-g"     = "toggle_locked_mode";
          "M-z"     = "toggle_fullscreen";
          "M-Up"    = "move_up";
          "M-Down"  = "move_down";
          "M-Left"  = "move_left";
          "M-Right" = "move_right";
          "M-t"     = "toggle_floating_pane";
        };
      };

      options = { };

    };
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
