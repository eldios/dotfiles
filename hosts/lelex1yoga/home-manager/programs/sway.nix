{ config, pkgs, inputs, ...}:

let
  inherit (config.colorScheme) colors;

  quick_menu = "rofi -show run -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail";
  full_menu = "rofi -show drun -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail";

  lockscreen = "swaylock -c '#000000'";

  daynightscreen = "wlsunset -l 43.841667 -L 10.502778";

  powermenu = "wlogout";

in
{

  wayland.windowManager.sway = {

    enable = true;
    systemd.enable = true;

    package = pkgs.swayfx;

    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
    '';

    extraConfig = ''
    ''; # EOM extraConfig

    config = rec {

      bars = [
        { command = "waybar"; }
      ];

      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      # Use alacritty as default terminal
      terminal = "alacritty"; 
      menu = "rofi";

      startup = [
        { command = "syncthing-tray"; }
        { command = "${daynightscreen}"; }
        { command = "variety"; }
      ];

      output = {
        "Virtual-1" = {
          res = "1920x1080";
          mode = "1920x1080@60Hz";
          pos = "0,0"; 
          transform = "0";
        };
        # "*" = { # change background for all outputs
        #   bg = "~/.dotfiles/users/alex/extraConfig/wallpapers/synthwave-night-skyscrapers.jpg fill";
        # };
      };

      workspaceLayout = "default";

      keybindings = {
        "${modifier}+Return"          = "exec ${terminal}";

        "${modifier}+d"               = "exec ${full_menu}";
        "${modifier}+Shift+d"         = "exec ${quick_menu}";

        "${modifier}+Shift+c"         = "kill";
        "${modifier}+Shift+f"         = "fullscreen toggle";

        "${modifier}+Ctrl+q"          = "exec ${lockscreen}";

        "${modifier}+Shift+Ctrl+q"    = "exec ${powermenu}";

        "${modifier}+Shift+Ctrl+r"    = "reload";
        "${modifier}+Ctrl+r"          = "mode resize";

        "${modifier}+Shift+Space"     = "floating toggle";
        "${modifier}+Space"           = "focus mode_toggle";
        "${modifier}+u"               = "focus parent";

        "${modifier}+w"               = "layout toggle split";
        "${modifier}+s"               = "layout tabbed";
        "${modifier}+e"               = "layout default";

        "${modifier}+${left}"         = "focus left";
        "${modifier}+${down}"         = "focus down";
        "${modifier}+${up}"           = "focus up";
        "${modifier}+${right}"        = "focus right";

        "${modifier}+Shift+${left}"   = "move left";
        "${modifier}+Shift+${down}"   = "move down";
        "${modifier}+Shift+${up}"     = "move up";
        "${modifier}+Shift+${right}"  = "move right";

        "${modifier}+Ctrl+${left}"    = "workspace prev";
        "${modifier}+Ctrl+${right}"   = "workspace next";

        "${modifier}+Alt+${left}"     = "move workspace to output left";
        "${modifier}+Alt+${down}"     = "move workspace to output down";
        "${modifier}+Alt+${up}"       = "move workspace to output up";
        "${modifier}+Alt+${right}"    = "move workspace to output right";

        "${modifier}+1"               = "workspace number 1";
        "${modifier}+2"               = "workspace number 2";
        "${modifier}+3"               = "workspace number 3";
        "${modifier}+4"               = "workspace number 4";
        "${modifier}+5"               = "workspace number 5";
        "${modifier}+6"               = "workspace number 6";
        "${modifier}+7"               = "workspace number 7";
        "${modifier}+8"               = "workspace number 8";
        "${modifier}+9"               = "workspace number 9";
        "${modifier}+0"               = "workspace number 10";

        "${modifier}+Shift+1"         = "move container to workspace number 1";
        "${modifier}+Shift+2"         = "move container to workspace number 2";
        "${modifier}+Shift+3"         = "move container to workspace number 3";
        "${modifier}+Shift+4"         = "move container to workspace number 4";
        "${modifier}+Shift+5"         = "move container to workspace number 5";
        "${modifier}+Shift+6"         = "move container to workspace number 6";
        "${modifier}+Shift+7"         = "move container to workspace number 7";
        "${modifier}+Shift+8"         = "move container to workspace number 8";
        "${modifier}+Shift+9"         = "move container to workspace number 9";
        "${modifier}+Shift+0"         = "move container to workspace number 10";
      }; # EOM keybindings

    }; # EOM config

  }; # EOM wayland WM sway

} # EOF
# vim: set ts=2 sw=2 et ai list nu
