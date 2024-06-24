{ pkgs, ... }:
let
  modifier = "Mod4";

  # basic_menu = "${pkgs.dmenu}/bin/dmenu_run";
  quick_menu = "${pkgs.rofi}/bin/rofi -show run -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail";
  full_menu = "${pkgs.rofi}/bin/rofi -show drun -show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail";

  lockscreen = "${pkgs.i3lock}/bin/i3lock -c 000000";

  daynightscreen = "${pkgs.redshift}/bin/redshift -l 43.841667:10.502778";

  logout = "${pkgs.wlogout}/bin/wlogout";

  mail = "mailspring --password-store=\"gnome-libsecret\"";

  terminal = "${pkgs.kitty}/bin/kitty";

  screenshot_select = "${pkgs.flameshot}/bin/flameshot gui -c";
  screenshot_full = "${pkgs.flameshot}/bin/flameshot gui";
in
{
  home = {
    packages = with pkgs; [
      feh
      nitrogen
    ];
  };

  services.picom = {
    enable = true;

    backend = "glx";
    vSync = true;

    fade = true;
    fadeDelta = 3;
    activeOpacity = 1.00;
    inactiveOpacity = 0.98;

    opacityRules = [
      "100:class_g *?= 'Rofi'"
      "100:class_g *?= 'i3lock'"
    ];
  };

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        uiColor = "#FFFFFF";
        showHelp = false;
      };
    };
  };

  xsession.windowManager.i3 = {
    enable = true;

    package = pkgs.i3-gaps;

    config = {
      inherit modifier;

      gaps = {
        inner = 5;
        outer = 2;

        smartBorders = "on";
        smartGaps = true;
      };

      window = {
        border = 0;
        hideEdgeBorders = "both";
      };

      assigns = { };

      modes.resize = {
        "h" = "resize grow width 10 px or 10 ppt";
        "j" = "resize shrink height 10 px or 10 ppt";
        "k" = "resize grow height 10 px or 10 ppt";
        "l" = "resize shrink width 10 px or 10 ppt";

        "Escape" = "mode default";
        "Return" = "mode default";
      };

      keybindings = {
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+a" = "focus parent";

        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";

        "${modifier}+Ctrl+h" = "resize grow width 10 px or 10 ppt";
        "${modifier}+Ctrl+j" = "resize shrink height 10 px or 10 ppt";
        "${modifier}+Ctrl+k" = "resize grow height 10 px or 10 ppt";
        "${modifier}+Ctrl+l" = "resize shrink width 10 px or 10 ppt";

        "${modifier}+Shift+s" = "exec ${screenshot_select}";
        "${modifier}+Shift+a" = "exec ${screenshot_full}";

        "${modifier}+Shift+m" = "exec ${mail}";

        "${modifier}+d" = "exec ${full_menu}";
        "${modifier}+Shift+d" = "exec ${quick_menu}";

        "${modifier}+Return" = "exec ${terminal}";

        "${modifier}+Shift+0" = "move container to workspace number 10";
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";


        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space" = " focus mode_toggle";
        "${modifier}+f" = " fullscreen toggle";

        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+minus" = " scratchpad show";

        "${modifier}+Ctrl+q" = "exec ${lockscreen}";
        "${modifier}+Ctrl+Shift+q" = "exec ${logout}";

        "${modifier}+Shift+c" = "kill";
        "${modifier}+Shift+Ctrl+r" = "restart";
        "${modifier}+Shift+r" = "reload";

        "${modifier}+r" = " mode resize";

        "${modifier}+e" = " layout toggle split";
        "${modifier}+w" = " layout tabbed";
        "${modifier}+s" = " layout stacking";
        "${modifier}+v" = " split v";
        "${modifier}+Shift+v" = " split h";

        "XF86MonBrightnessDown" = "exec sudo light -U 5%";
        "XF86MonBrightnessUp" = "exec sudo light -A 5%";

        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "Shift+XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPlay" = "exec playerctl -p spotify play-pause";
        "XF86AudioNext" = "exec playerctl -p spotify next";
        "XF86AudioPrev" = "exec playerctl -p spotify previous";
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu

