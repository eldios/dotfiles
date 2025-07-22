{ pkgs, ... }:
let
  modifier = "Mod4";

  # Use the unified rofi scripts from rofi.nix
  quick_menu = "rofi-run";
  full_menu = "rofi-drun";
  file_menu = "rofi-filebrowser";
  window_menu = "rofi-window";

  lockscreen = "${pkgs.i3lock}/bin/i3lock -c 000000";

  daynightscreen = "${pkgs.redshift}/bin/redshift -l 43.841667:10.502778";

  logout = "${pkgs.wlogout}/bin/wlogout";

  mail = "mailspring --password-store=\"gnome-libsecret\"";

  terminal = "${pkgs.kitty}/bin/kitty";

  screenshot_select = "flameshot gui -c";
  screenshot_full = "flameshot gui";
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

  xsession.windowManager.i3 = {
    enable = true;

    package = pkgs.i3-gaps;

    config = {
      inherit modifier;

      # Monitor configuration for dual display setup
      startup = [
        {
          command = ''${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-A-1 --mode 3440x1440 --rate 59.94 --pos 0x0 --primary --output HDMI-A-2 --mode 2560x1440 --rate 143.87 --pos 3440x0'';
          always = true;
          notification = false;
        }
      ];

      gaps = {
        inner = 5;
        outer = 2;

        smartBorders = "on";
        smartGaps = true;
      };

      window = {
        border = 0;
        hideEdgeBorders = "both";

        commands = [
          {
            command = "border off";
            criteria = {
              class = "screenkey";
            };
          }
          {
            command = "floating true";
            criteria = {
              class = "screenkey";
            };
          }
        ];
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
        "${modifier}+Shift+e" = "exec ${file_menu}"; # Added file menu
        "${modifier}+Shift+w" = "exec ${window_menu}"; # Added window menu

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

        "XF86MonBrightnessDown" = "exec sudo ${pkgs.light}/bin/light -U 5%";
        "XF86MonBrightnessUp" = "exec sudo ${pkgs.light}/bin/light -A 5%";

        # FIXME: Verify package for pactl (e.g., pkgs.pulseaudio or pkgs.pipewire)
        "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "Shift+XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
        "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify play-pause";
        "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify next";
        "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl -p spotify previous";
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu

