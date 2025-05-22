# common/home-manager/eldios/programs/eww.nix
{ config, pkgs, lib, ... }:

let
  # Helper to access Stylix colors easily
  colors = config.lib.stylix.colors;
in
{
  # Enable Eww program
  programs.eww = {
    enable = true;
    configDir = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/eww";
    package = pkgs.eww; # Using wayland variant for Hyprland compatibility
  };

  # Ensure required fonts are installed
  home.packages = with pkgs; [
    font-awesome
  ];

  # Create Eww configuration files using home.file
  home.file = {
    # Eww Yuck file (widget definitions)
    ".config/eww/eww.yuck".text = ''
      ;; Main bar window
      (defwindow eww_bar
        :monitor 0
        :geometry (geometry :x "0%" :y "5px" :width "99%" :height "35px" :anchor "top center")
        :stacking "fg"
        :reserve (struts :side "top" :distance "45px") ;; Increased distance for a slightly taller bar + gap
        :windowtype "dock"
        :wm-ignore false
        (centerbox :orientation "h"
          (box :class "eww_bar_left" :halign "start" :spacing 10
            (workspaces_widget)
          )
          (box :class "eww_bar_center" :halign "center" :spacing 10
            (clock_widget)
          )
          (box :class "eww_bar_right" :halign "end" :spacing 10
            (cpu_widget)
            (memory_widget)
            (volume_widget)
          )
        )
      )

      ;; Clock
      (defpoll time_val :interval "1s" "date +'%H:%M:%S'")
      (defwidget clock_widget []
        (box :class "clock" :halign "center"
          (label :text time_val)
        )
      )

      ;; Workspaces
      (defpoll workspaces :interval "1s" "~/.config/eww/scripts/get-workspaces.sh")
      (defwidget workspaces_widget []
        (box :class "workspaces" :orientation "h" :spacing 5
          (literal :content workspaces)
        )
      )

      ;; CPU Usage
      (defpoll cpu_usage :interval "2s" "echo $(LANG=C top -bn1 | awk '/Cpu\\(s\\):/ {print $2 + $4}')%")
      (defwidget cpu_widget []
        (box :class "cpu" :orientation "h" :spacing 5
          (label :text "󰻠") ;; CPU icon from Nerd Font
          (label :text cpu_usage)
        )
      )

      ;; Memory Usage
      (defpoll mem_usage :interval "2s" "LANG=C free -m | awk 'NR==2{printf \"%.0f%%\", $3*100/$2 }'")
      (defwidget memory_widget []
        (box :class "memory" :orientation "h" :spacing 5
          (label :text "󰍛") ;; Memory icon from Nerd Font
          (label :text mem_usage)
        )
      )

      ;; Volume Widget
      (defpoll volume :interval "1s" "~/.config/eww/scripts/get-volume.sh")
      (defwidget volume_widget []
        (box :class "volume" :orientation "h" :spacing 5
          (label :text "󰕾") ;; Volume icon from Nerd Font
          (label :text volume)
        )
      )
    '';

    # Eww SCSS file (styling)
    ".config/eww/eww.scss".text = ''
      /* Variables from Stylix */
      $bg: #${colors.base00};
      $fg: #${colors.base05};
      $accent_cyan: #${colors.base0B};
      $accent_pink: #${colors.base0D};
      $accent_yellow: #${colors.base0A};
      $accent_green: #${colors.base0C};
      $inactive: #${colors.base03};
      $bar_radius: 8px;
      $widget_padding: 0 10px;

      /* Bar styling */
      .eww_bar {
        background-color: transparent; /* Make bar background transparent to see Hyprland blur if any */
        color: $fg;
        font-family: "${config.stylix.fonts.monospace.name}", "Font Awesome 6 Free", "Symbols Nerd Font";
        font-size: ${builtins.toString config.stylix.fonts.sizes.applications}px;
        padding: 0 5px; /* Padding for the overall bar content */
      }

      .eww_bar_left, .eww_bar_center, .eww_bar_right {
        padding: 2px 8px; /* Padding around groups of widgets */
        background-color: rgba($bg, 0.7); /* Semi-transparent background for widget groups */
        border-radius: $bar_radius;
        margin: 2px 0px; /* Small vertical margin for the group background */
      }

      /* Individual widget styling */
      .clock, .workspaces, .cpu, .memory, .volume {
        color: $fg;
        padding: $widget_padding;
      }

      .workspaces button {
          color: $inactive;
          &.active { color: $accent_cyan; }
          &.occupied { color: $fg; }
      }

      .cpu label:first-child { color: $accent_pink; } /* Icon color */
      .memory label:first-child { color: $accent_yellow; } /* Icon color */
      .volume label:first-child { color: $accent_green; } /* Icon color */
    '';

    # Scripts for widgets
    ".config/eww/scripts/get-workspaces.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Script to get Hyprland workspaces

        workspaces() {
          # Get active workspace
          active=$(hyprctl activeworkspace -j | jq '.id')

          # Generate workspace buttons
          echo "(box :class \"workspaces\" :orientation \"h\" :spacing 5"
          for i in {1..9}; do
            # Check if workspace is occupied
            occupied=$(hyprctl workspaces -j | jq ".[] | select(.id == $i) | .id" | wc -l)

            if [ "$i" -eq "$active" ]; then
              echo "  (button :class \"active\" :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
            elif [ "$occupied" -eq 1 ]; then
              echo "  (button :class \"occupied\" :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
            else
              echo "  (button :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
            fi
          done
          echo ")"
        }

        workspaces
      '';
    };

    ".config/eww/scripts/get-volume.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Script to get volume percentage

        volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '[0-9]+(?=%)' | head -1)
        echo "$volume%"
      '';
    };
  };
}
