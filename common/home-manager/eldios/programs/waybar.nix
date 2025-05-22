{ pkgs, config, ... }:

let
  # Dependencies
  cat = "${pkgs.coreutils}/bin/cat";
  cut = "${pkgs.coreutils}/bin/cut";
  grep = "${pkgs.gnugrep}/bin/grep";
  tail = "${pkgs.coreutils}/bin/tail";
  wc = "${pkgs.coreutils}/bin/wc";
  xargs = "${pkgs.findutils}/bin/xargs";

  jq = "${pkgs.jq}/bin/jq";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";

  # jsonOutput: A helper function to generate JSON strings for Waybar custom modules.
  # It takes a module name and a set of attributes (text, tooltip, alt, class, percentage)
  # and creates a shell script that outputs these attributes in the JSON format Waybar expects.
  # The 'pre' argument allows prepending shell commands to calculate values before generating JSON.
  jsonOutput = name: { pre ? "", text ? "", tooltip ? "", alt ? "", class ? "", percentage ? "" }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
      set -euo pipefail # Exit on error, unbound variable, or pipe failure
      ${pre} # Execute any preliminary commands passed via the 'pre' argument
      ${jq} -cn \
      --arg text "${text}" \
      --arg tooltip "${tooltip}" \
      --arg alt "${alt}" \
      --arg class "${class}" \
      --arg percentage "${percentage}" \
      '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
    ''}/bin/waybar-${name}";
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar.overrideAttrs (oa: {
      mesonFlags = (oa.mesonFlags or  [ ]) ++ [ "-Dexperimental=true" ];
    });
    systemd.enable = false;

    style = ''
      * {
          /* Default font for text, assuming FontAwesome is available for icons */
          font-family: "${config.stylix.fonts.monospace.name}", FontAwesome;
          font-size: ${builtins.toString config.stylix.fonts.sizes.applications}px;
          /* Other global properties like padding, margin can be set here if needed */
      }

      window#waybar {
          background-color: #${config.lib.stylix.colors.base00}E6; /* base00 with ~90% alpha */
          color: #${config.lib.stylix.colors.base05}; /* Main foreground color */
          border-radius: 10px; /* Rounded corners for the bar */
          border: 1px solid #${config.lib.stylix.colors.base02}; /* Subtle border */
      }

      /* Workspace buttons */
      #workspaces button {
          padding: 2px 10px;
          margin: 2px 2px;
          color: #${config.lib.stylix.colors.base04}; /* Dimmed foreground for inactive workspaces */
          background-color: transparent;
          border-radius: 8px;
          transition: all 0.3s ease;
      }

      #workspaces button.active {
          color: #${config.lib.stylix.colors.base0B}; /* Neon Cyan for active workspace text */
          background-color: #${config.lib.stylix.colors.base01}BF; /* Darker bg with alpha for active */
          border: 1px solid #${config.lib.stylix.colors.base0B}; /* Neon Cyan border */
      }

      #workspaces button.focused { /* Often the same as active or a slight variation */
          color: #${config.lib.stylix.colors.base0D}; /* Neon Pink for focused workspace (often indicates monitor focus) */
          background-color: #${config.lib.stylix.colors.base02}99; /* Slightly different bg for focus */
      }

      #workspaces button.urgent {
          color: #${config.lib.stylix.colors.base00};
          background-color: #${config.lib.stylix.colors.base0A}; /* Neon Yellow for urgent */
          border-radius: 8px;
      }

      /* Module styling */
      #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #custom-menu, #custom-seperator-left, #custom-seperator-right, #custom-gammastep, #custom-currentplayer, #custom-player, #idle_inhibitor, #backlight {
          padding: 0 8px;
          margin: 2px 0px;
          color: #${config.lib.stylix.colors.base05}; /* Default module text color */
      }
      
      #clock {
        color: #${config.lib.stylix.colors.base0E}; /* Neon Pink variant for clock */
      }

      #battery.charging, #battery.plugged {
          color: #${config.lib.stylix.colors.base0C}; /* Neon Green for charging */
      }

      #battery.critical:not(.charging) {
          background-color: #${config.lib.stylix.colors.base08}; /* Accent Pink/Magenta for critical battery */
          color: #${config.lib.stylix.colors.base00}; /* Dark text on bright critical background */
          border-radius: 4px;
          margin: 2px 2px;
      }

      #pulseaudio.muted {
        color: #${config.lib.stylix.colors.base03}; /* Dimmed color for muted audio */
      }
      
      #network.disconnected {
        color: #${config.lib.stylix.colors.base0F}; /* Bright Red/Orange for disconnected */
      }

      /* Tooltip styling */
      tooltip {
          background-color: #${config.lib.stylix.colors.base01};
          color: #${config.lib.stylix.colors.base05};
          border: 1px solid #${config.lib.stylix.colors.base03};
          border-radius: 8px;
          padding: 8px;
      }

      tooltip label {
          color: #${config.lib.stylix.colors.base05};
      }
    '';

    settings = {
      primary = {
        mode = "dock";
        layer = "top";
        height = 30;
        margin-top = 10;
        margin-left = 13;
        margin-right = 13;
        position = "top";

        modules-left = [
          "custom/menu" # Custom module for a main application menu
          "sway/workspaces"
          "custom/seperator-left" # Decorative separator
          "sway/window"
        ];

        modules-center = [
          "pulseaudio"
          "clock"
          "cava"
        ];

        modules-right = [
          "tray"
          "network"
          "battery"
          "custom/seperator-right" # Decorative separator
          "cpu"
          "memory"
          "backlight"
        ];

        "tray" = {
          "spacing" = 8;
        };

        clock = {
          interval = 1;
          format = "{:%a, %b %d   %r}";
          # on-click = "mode";
          tooltip-format = ''
            <tt><small>{calendar}</small></tt>
          ''; # TODO: Implement gcal: {gcal --starting-day=1 | sed -e 's|<|\[|g' -e 's|>|\]|g}
        };

        cava = {
          framerate = 30;
          autosens = 1;
          # sensitivity = 100;
          bars = 10;
          lower_cutoff_freq = 50;
          higher_cutoff_freq = 15000;
          method = "pulse";
          source = "auto";
          stereo = true;
          reverse = false;
          bar_delimiter = 0;
          monstercat = false;
          waves = false;
          noise_reduction = 0.77;
          input_delay = 2;
          format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          actions = {
            # on-click-right = "mode";
            # on-click-left = "${playerctl} play-pause";
          };
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = [ "󰋋" "󰋋" "󰋋" ];
          };
          on-click = pavucontrol;
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳";
            deactivated = "󰒲";
          };
        };

        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          onclick = "";
        };

        "sway/window" = {
          max-length = 25;
          format = "{title}";
          on-click = "swaymsg kill";
          all-outputs = true;
        };

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        cpu = {
          interval = 15;
          format = "  {}%";
          max-length = 10;
        };

        memory = {
          interval = 30;
          format = "  {}%";
          max-length = 10;
        };

        network = {
          interval = 3;
          format-wifi = "󰖩 ";
          format-ethernet = "󰈁 Connected";
          format-disconnected = "";
          tooltip-format = ''
              {essid}
            󱘖  {ifname}
              {ipaddr}/{cidr}
            󱚺  {bandwidthUpBits}
            󱚶  {bandwidthDownBits}'';
          on-click = ""; #FIXME: Add on-click setup for preview like macos
        };

        backlight = {
          tooltip = false;
          format = " {}%";
          interval = 1;
          on-scroll-up = "${pkgs.light}/bin/light -A 5";
          on-scroll-down = "${pkgs.light}/bin/light -U 5";
        };

        "custom/seperator-left" = {
          return-type = "json";
          exec = jsonOutput "seperator-left" {
            text = "";
            # tooltip = ''$(${cat} /etc/os-release | ${grep} PRETTY_NAME | ${cut} -d '"' -f2)'';
          };
        };

        "custom/seperator-right" = {
          return-type = "json";
          exec = jsonOutput "seperator-right" {
            text = "";
            # tooltip = ''$(${cat} /etc/os-release | ${grep} PRETTY_NAME | ${cut} -d '"' -f2)'';
          };
        };

        "custom/menu" = {
          # Displays a Linux distribution logo ()
          return-type = "json";
          exec = jsonOutput "menu" {
            # Uses the jsonOutput helper
            text = ""; # Icon representing the menu (NixOS logo)
            tooltip = ''$(${cat} /etc/os-release | ${grep} PRETTY_NAME | ${cut} -d '"' -f2)''; # Tooltip shows OS pretty name
          };
          on-click-left = "${pkgs.rofi}/bin/rofi -S drun -x 10 -y 10 -W 25% -H 60%"; # Left-click opens Rofi application launcher
          on-click-right = "swaymsg scratchpad show"; # Right-click shows the scratchpad workspace
        };

        "custom/hostname" = {
          # Displays user@hostname
          exec = "echo $USER@$HOSTNAME"; # Simple echo command
          on-click = "${systemctl} --user restart waybar"; # Click to restart Waybar
        };

        "custom/gammastep" = {
          # Controls and displays status for Gammastep (screen temperature)
          interval = 5; # Update interval
          return-type = "json";
          exec = jsonOutput "gammastep" {
            # Uses jsonOutput helper
            pre = '' # Shell script to determine Gammastep status and period (Day/Night)
              if unit_status="$(${systemctl} --user is-active gammastep)"; then
              status="$unit_status ($(${journalctl} --user -u gammastep.service -g 'Period: ' | ${tail} -1 | ${cut} -d ':' -f6 | ${xargs}))" # Extracts period if active
              else
              status="$unit_status" # inactive
              fi
            '';
            alt = "\${status:-inactive}"; # Fallback alt text
            tooltip = "Gammastep is $status"; # Tooltip shows detailed status
          };
          format = "{icon}"; # Display format is just an icon
          format-icons = {
            "activating" = "󰁪 ";
            "deactivating" = "󰁪 ";
            "inactive" = "? ";
            "active (Night)" = " ";
            "active (Nighttime)" = " ";
            "active (Transition (Night)" = " ";
            "active (Transition (Nighttime)" = " ";
            "active (Day)" = " ";
            "active (Daytime)" = " ";
            "active (Transition (Day)" = " ";
            "active (Transition (Daytime)" = " ";
          };
          on-click = "${systemctl} --user is-active gammastep && ${systemctl} --user stop gammastep || ${systemctl} --user start gammastep"; # Toggles Gammastep on click
        };

        "custom/currentplayer" = {
          # Shows the current media player icon and count of other players
          interval = 2; # Update interval
          return-type = "json";
          exec = jsonOutput "currentplayer" {
            # Uses jsonOutput helper
            pre = '' # Shell script to get current player name and count of available players
              player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No player active" | ${cut} -d '.' -f1)" # Get current player or "No player active"
              count="$(${playerctl} -l 2>/dev/null | ${wc} -l)" # Count total active players
              if ((count > 1)); then
                more=" +$((count - 1))" # If more than one, show "+N"
              else
                more=""
              fi
            '';
            alt = "$player"; # Alt text shows current player name
            tooltip = "$player ($count available)"; # Tooltip shows current player and total available
            text = "$more"; # Displays "+N" if multiple players are active
          };
          format = "{icon}{}"; # Displays icon and the "+N" text
          format-icons = {
            "No player active" = " ";
            "Celluloid" = "󰎁 ";
            "spotify" = " ";
            "ncspot" = " ";
            "qutebrowser" = "󰖟 ";
            "firefox" = " ";
            "discord" = " 󰙯 ";
            "sublimemusic" = " ";
            "kdeconnect" = "󰄡 ";
            "chromium" = " ";
            "brave" = " ";
          };
          on-click = "${playerctld} shift"; # Left-click cycles to the next player
          on-click-right = "${playerctld} unshift"; # Right-click cycles to the previous player
        };

        "custom/player" = {
          # Displays metadata of the currently playing media
          exec-if = "${playerctl} status 2>/dev/null"; # Only run if a player is active
          # Retrieves metadata (title, artist, status, album) from playerctl and formats it as JSON for Waybar
          exec = ''${playerctl} metadata --format '{"text": "{{title}} - {{artist}}", "alt": "{{status}}", "tooltip": "{{title}} - {{artist}} ({{album}})"}' 2>/dev/null '';
          return-type = "json"; # Expects JSON output from exec command
          interval = 2; # Update interval
          max-length = 30;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰏤 🔊";
            "Paused" = "󰐊  ";
            "Stopped" = "󰐊";
          };
          on-click = "${playerctl} play-pause";
        };
      };
    };
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
