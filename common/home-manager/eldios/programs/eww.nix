# common/home-manager/eldios/programs/eww.nix
{ config, pkgs, ... }:

let
  # Helper to access Stylix colors easily
  colors = config.lib.stylix.colors;
in
{
  # Enable Eww program
  programs.eww = {
    enable = true;
    configDir = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/eww";
    package = pkgs.eww;
  };

  # Ensure required fonts and dependencies are installed
  home.packages = with pkgs; [
    font-awesome
    nerd-fonts.symbols-only
    jq # Required for workspace scripts
    socat # For hyprland event listening
  ];

  # Create Eww configuration files using home.file
  home.file = {
    # Eww Yuck file (widget definitions)
    ".config/eww/eww.yuck".text = ''
      ;; Variables for bar mode
      (defvar bar_mode "persistent")

      ;; Main bar window - monitor 0
      (defwindow eww_bar_0
        :monitor 0
        :geometry (geometry :x "0%" :y "5px" :width "99%" :height "35px" :anchor "top center")
        :stacking "fg"
        :reserve {bar_mode == "persistent" ? "(struts :side \"top\" :distance \"45px\")" : "false"}
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
            (battery_widget)
          )
        )
      )

      ;; Main bar window - monitor 1
      (defwindow eww_bar_1
        :monitor 1
        :geometry (geometry :x "0%" :y "5px" :width "99%" :height "35px" :anchor "top center")
        :stacking "fg"
        :reserve {bar_mode == "persistent" ? "(struts :side \"top\" :distance \"45px\")" : "false"}
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
            (battery_widget)
          )
        )
      )

      ;; Clock with date on hover
      (defpoll time_val :interval "1s" "date +'%H:%M:%S'")
      (defpoll date_val :interval "60s" "date +'%A, %B %d'")
      (defwidget clock_widget []
        (box :class "clock" :halign "center"
          (label :text time_val :tooltip date_val)
        )
      )

      ;; Workspaces - auto-detects WM
      (defpoll workspaces :interval "1s" "~/.config/eww/scripts/get-workspaces.sh")
      (defwidget workspaces_widget []
        (box :class "workspaces" :orientation "h" :spacing 5
          (literal :content workspaces)
        )
      )

      ;; CPU Usage with temperature
      (defpoll cpu_usage :interval "2s" "~/.config/eww/scripts/get-cpu.sh")
      (defwidget cpu_widget []
        (box :class "cpu" :orientation "h" :spacing 5
          (label :text "󰻠")
          (label :text cpu_usage)
        )
      )

      ;; Memory Usage
      (defpoll mem_usage :interval "2s" "~/.config/eww/scripts/get-memory.sh")
      (defwidget memory_widget []
        (box :class "memory" :orientation "h" :spacing 5
          (label :text "󰍛")
          (label :text mem_usage)
        )
      )

      ;; Volume Widget with mute detection
      (defpoll volume :interval "1s" "~/.config/eww/scripts/get-volume.sh")
      (defwidget volume_widget []
        (eventbox :onclick "~/.config/eww/scripts/toggle-volume.sh"
          (box :class "volume" :orientation "h" :spacing 5
            (label :text volume)
          )
        )
      )

      ;; Battery Widget (only shows if battery exists)
      (defpoll battery :interval "10s" "~/.config/eww/scripts/get-battery.sh")
      (defwidget battery_widget []
        (box :class "battery" :orientation "h" :spacing 5 :visible {battery != ""}
          (label :text battery)
        )
      )
    '';

    # Eww SCSS file (styling)
    ".config/eww/eww.scss".text = ''
      /* Stylix color variables */
      $bg: #${colors.base00};
      $bg-alt: #${colors.base01};
      $fg: #${colors.base05};
      $fg-alt: #${colors.base04};
      $red: #${colors.base08};
      $orange: #${colors.base09};
      $yellow: #${colors.base0A};
      $green: #${colors.base0B};
      $cyan: #${colors.base0C};
      $blue: #${colors.base0D};
      $purple: #${colors.base0E};
      $brown: #${colors.base0F};
      
      $bar_radius: 8px;
      $widget_padding: 0 10px;

      /* Global bar styling */
      .eww_bar {
        background-color: transparent;
        color: $fg;
        font-family: "${config.stylix.fonts.monospace.name}", "Symbols Nerd Font", "Font Awesome 6 Free";
        font-size: ${builtins.toString config.stylix.fonts.sizes.applications}px;
        padding: 0 5px;
      }

      .eww_bar_left, .eww_bar_center, .eww_bar_right {
        padding: 4px 12px;
        background-color: rgba(${colors.base00-rgb-r}, ${colors.base00-rgb-g}, ${colors.base00-rgb-b}, 0.8);
        border-radius: $bar_radius;
        margin: 2px 4px;
        border: 1px solid rgba(${colors.base03-rgb-r}, ${colors.base03-rgb-g}, ${colors.base03-rgb-b}, 0.3);
      }

      /* Widget styling */
      .clock, .workspaces, .cpu, .memory, .volume, .battery {
        color: $fg;
        padding: $widget_padding;
      }

      .workspaces button {
        color: $fg-alt;
        background: transparent;
        border: none;
        padding: 4px 8px;
        border-radius: 4px;
        margin: 0 2px;
        transition: all 0.2s ease;
        
        &.active { 
          color: $cyan; 
          background: rgba(${colors.base0C-rgb-r}, ${colors.base0C-rgb-g}, ${colors.base0C-rgb-b}, 0.2);
        }
        &.occupied { 
          color: $fg; 
          background: rgba(${colors.base05-rgb-r}, ${colors.base05-rgb-g}, ${colors.base05-rgb-b}, 0.1);
        }
        &:hover {
          background: rgba(${colors.base05-rgb-r}, ${colors.base05-rgb-g}, ${colors.base05-rgb-b}, 0.1);
        }
      }

      .cpu label:first-child { color: $purple; }
      .memory label:first-child { color: $yellow; }
      .volume label:first-child { color: $green; }
      .battery label:first-child { color: $orange; }

      /* Hover effects */
      .cpu, .memory, .volume, .battery {
        transition: all 0.2s ease;
        &:hover {
          background: rgba(${colors.base05-rgb-r}, ${colors.base05-rgb-g}, ${colors.base05-rgb-b}, 0.1);
          border-radius: 4px;
        }
      }
    '';

    # Bar toggle script
    ".config/eww/scripts/toggle-bar-mode.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Toggle between persistent and autohide modes for Eww bar

        CONFIG_FILE="$HOME/.config/eww/bar_mode"
        
        # Read current mode, default to persistent
        if [ -f "$CONFIG_FILE" ]; then
          current_mode=$(cat "$CONFIG_FILE")
        else
          current_mode="persistent"
        fi

        # Toggle mode
        if [ "$current_mode" = "persistent" ]; then
          new_mode="autohide"
        else
          new_mode="persistent"
        fi

        # Save new mode
        echo "$new_mode" > "$CONFIG_FILE"

        # Update Eww variable
        ${pkgs.eww}/bin/eww update bar_mode="$new_mode"

        # Close and reopen bars to apply changes
        ${pkgs.eww}/bin/eww close eww_bar_0 eww_bar_1 2>/dev/null || true
        
        # Detect available monitors and open bars
        if command -v hyprctl >/dev/null 2>&1 && pgrep -x "Hyprland" >/dev/null; then
          # Hyprland monitor detection
          monitors=$(hyprctl monitors -j | jq -r '.[].id')
          for monitor in $monitors; do
            ${pkgs.eww}/bin/eww open "eww_bar_$monitor" 2>/dev/null || true
          done
        elif command -v swaymsg >/dev/null 2>&1 && pgrep -x "sway" >/dev/null; then
          # Sway monitor detection
          monitors=$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name' | nl -v0 -nln | cut -f1)
          for monitor in $monitors; do
            ${pkgs.eww}/bin/eww open "eww_bar_$monitor" 2>/dev/null || true
          done
        else
          # Fallback - open first two bars
          ${pkgs.eww}/bin/eww open eww_bar_0 2>/dev/null || true
          ${pkgs.eww}/bin/eww open eww_bar_1 2>/dev/null || true
        fi

        # Notify user of mode change
        if command -v notify-send >/dev/null 2>&1; then
          notify-send "Eww Bar" "Mode changed to: $new_mode"
        fi
      '';
    };

    # Enhanced workspace script with WM detection
    ".config/eww/scripts/get-workspaces.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        # Auto-detect window manager and get workspaces

        if command -v hyprctl >/dev/null 2>&1 && pgrep -x "Hyprland" >/dev/null; then
          # Hyprland workspaces
          active=$(hyprctl activeworkspace -j | jq '.id')
          occupied=$(hyprctl workspaces -j | jq '.[].id' | sort -n)
          
          echo "(box :class \"workspaces\" :orientation \"h\" :spacing 5"
          for i in {1..9}; do
            if [ "$i" -eq "$active" ]; then
              echo "  (button :class \"active\" :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
            elif echo "$occupied" | grep -q "^$i$"; then
              echo "  (button :class \"occupied\" :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
            else
              echo "  (button :onclick \"hyprctl dispatch workspace $i\" \"$i\")"
            fi
          done
          echo ")"
          
        elif command -v swaymsg >/dev/null 2>&1 && pgrep -x "sway" >/dev/null; then
          # Sway workspaces
          workspaces=$(swaymsg -t get_workspaces)
          active=$(echo "$workspaces" | jq '.[] | select(.focused==true) | .num')
          
          echo "(box :class \"workspaces\" :orientation \"h\" :spacing 5"
          for i in {1..9}; do
            visible=$(echo "$workspaces" | jq ".[] | select(.num==$i) | .num" | wc -l)
            if [ "$i" -eq "$active" ]; then
              echo "  (button :class \"active\" :onclick \"swaymsg workspace $i\" \"$i\")"
            elif [ "$visible" -eq 1 ]; then
              echo "  (button :class \"occupied\" :onclick \"swaymsg workspace $i\" \"$i\")"
            else
              echo "  (button :onclick \"swaymsg workspace $i\" \"$i\")"
            fi
          done
          echo ")"
        else
          # Fallback - static workspaces
          echo "(box :class \"workspaces\" :orientation \"h\" :spacing 5"
          for i in {1..9}; do
            echo "  (button \"$i\")"
          done
          echo ")"
        fi
      '';
    };

    # Enhanced CPU script
    ".config/eww/scripts/get-cpu.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        cpu_usage=$(LANG=C top -bn1 | awk '/Cpu\(s\):/ {print int($2 + $4)}')
        echo "$cpu_usage%"
      '';
    };

    # Enhanced memory script
    ".config/eww/scripts/get-memory.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        mem_usage=$(LANG=C free -m | awk 'NR==2{printf "%.0f%%", $3*100/$2 }')
        echo "$mem_usage"
      '';
    };

    # Enhanced volume script with icon
    ".config/eww/scripts/get-volume.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if command -v wpctl >/dev/null 2>&1; then
          volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
          muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED" || echo "")
          
          if [ -n "$muted" ]; then
            echo "󰖁 $volume%"
          elif [ "$volume" -gt 50 ]; then
            echo "󰕾 $volume%"
          elif [ "$volume" -gt 0 ]; then
            echo "󰖀 $volume%"
          else
            echo "󰕿 $volume%"
          fi
        else
          volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '[0-9]+(?=%)' | head -1)
          echo "󰕾 $volume%"
        fi
      '';
    };

    # Volume toggle script
    ".config/eww/scripts/toggle-volume.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if command -v wpctl >/dev/null 2>&1; then
          wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        else
          pactl set-sink-mute @DEFAULT_SINK@ toggle
        fi
      '';
    };

    # Battery script
    ".config/eww/scripts/get-battery.sh" = {
      executable = true;
      text = ''
        #!/bin/sh
        if [ -d "/sys/class/power_supply/BAT0" ] || [ -d "/sys/class/power_supply/BAT1" ]; then
          for bat in /sys/class/power_supply/BAT*; do
            if [ -f "$bat/capacity" ]; then
              capacity=$(cat "$bat/capacity")
              status=$(cat "$bat/status")
              
              if [ "$status" = "Charging" ]; then
                icon="󰂄"
              elif [ "$capacity" -gt 80 ]; then
                icon="󰁹"
              elif [ "$capacity" -gt 60 ]; then
                icon="󰂀"
              elif [ "$capacity" -gt 40 ]; then
                icon="󰁾"
              elif [ "$capacity" -gt 20 ]; then
                icon="󰁼"
              else
                icon="󰁺"
              fi
              
              echo "$icon $capacity%"
              break
            fi
          done
        fi
      '';
    };
  };
}
