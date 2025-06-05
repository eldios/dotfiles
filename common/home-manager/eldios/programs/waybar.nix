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
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  df = "${pkgs.coreutils}/bin/df";

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
          font-family: "${config.stylix.fonts.monospace.name}", FontAwesome;
          font-size: ${builtins.toString config.stylix.fonts.sizes.applications}px;
      }

      window#waybar {
          background-color: #${config.lib.stylix.colors.base00};
          color: #${config.lib.stylix.colors.base05};
          border-radius: 12px;
          margin-top: 8px;
          margin-bottom: 4px;
          border: 1px solid #${config.lib.stylix.colors.base02};
          box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.3);
      }

      #workspaces {
          margin: 0 4px;
      }

      #workspaces button {
          padding: 0px 6px;
          margin: 0 2px;
          color: #${config.lib.stylix.colors.base04};
          background-color: transparent;
          border-radius: 6px;
          transition: all 0.3s ease;
      }

      #workspaces button.active {
          color: #${config.lib.stylix.colors.base0B};
          background-color: #${config.lib.stylix.colors.base01};
          border: 1px solid #${config.lib.stylix.colors.base0B};
      }

      #workspaces button.focused {
          color: #${config.lib.stylix.colors.base0D};
          background-color: #${config.lib.stylix.colors.base02};
      }

      #workspaces button.urgent {
          color: #${config.lib.stylix.colors.base00};
          background-color: #${config.lib.stylix.colors.base0A};
      }

      #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #custom-menu, #custom-seperator-left, #custom-seperator-right, #custom-gammastep, #custom-currentplayer, #custom-player, #idle_inhibitor, #backlight, #disk {
          padding: 0 10px;
          margin: 3px 0px;
          color: #${config.lib.stylix.colors.base05};
      }

      #clock {
          color: #${config.lib.stylix.colors.base0E};
      }

      #battery.charging, #battery.plugged {
          color: #${config.lib.stylix.colors.base0C};
      }

      #battery.critical:not(.charging) {
          background-color: #${config.lib.stylix.colors.base08};
          color: #${config.lib.stylix.colors.base00};
          border-radius: 4px;
          margin: 2px 2px;
      }

      #pulseaudio.muted {
          color: #${config.lib.stylix.colors.base03};
      }

      #network.disconnected {
          color: #${config.lib.stylix.colors.base0F};
      }

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
        height = 32;
        margin-top = 8;
        margin-left = 10;
        margin-right = 10;
        position = "top";

        modules-left = [
          "custom/menu"
          "hyprland/workspaces"
          "sway/workspaces"
          "custom/seperator-left"
          "hyprland/window"
        ];

        modules-center = [
          "pulseaudio"
          "clock"
          "cava"
        ];

        modules-right = [
          "tray"
          "network"
          "disk"
          "battery"
          "custom/seperator-right"
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
          tooltip-format = ''
            <tt><small>{calendar}</small></tt>
          '';
        };

        cava = {
          framerate = 30;
          autosens = 1;
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
          format-icons = [ " " "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
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

        "workspaces" = {
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
          format-wifi = "󰖩 {bandwidthUpBits} 󰖪 {bandwidthDownBits}";
          format-ethernet = "󰈁 {bandwidthUpBits} 󰖪 {bandwidthDownBits}";
          format-disconnected = "󰤯";
          tooltip-format = ''
              {essid}
            󱘖  {ifname}
              {ipaddr}/{cidr}
            󱚺  {bandwidthUpBits}
            󱚶  {bandwidthDownBits}'';
          on-click = "${nmcli} dev wifi connect"; #FIXME: Add on-click setup for preview like macos
        };

        backlight = {
          tooltip = false;
          format = " {}%";
          interval = 1;
          on-scroll-up = "${pkgs.light}/bin/light -A 5";
          on-scroll-down = "${pkgs.light}/bin/light -U 5";
        };

        disk = {
          interval = 60;
          format = "󰋊 {percentage}%";
          tooltip = "Disk Usage: {used} / {total}";
          path = "/";
        };

        "custom/seperator-left" = {
          return-type = "json";
          exec = jsonOutput "seperator-left" {
            text = "";
          };
        };

        "custom/seperator-right" = {
          return-type = "json";
          exec = jsonOutput "seperator-right" {
            text = "";
          };
        };

        "custom/menu" = {
          return-type = "json";
          exec = jsonOutput "menu" {
            text = "";
            tooltip = ''$(${cat} /etc/os-release | ${grep} PRETTY_NAME | ${cut} -d '"' -f2)'';
          };
          #on-click-left = "";
          #on-click-right = "";
        };

        "custom/hostname" = {
          exec = "echo $USER@$HOSTNAME";
          on-click = "${systemctl} --user restart waybar";
        };

        "custom/gammastep" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gammastep" {
            pre = ''
              if unit_status="$(${systemctl} --user is-active gammastep)"; then
              status="$unit_status ($(${journalctl} --user -u gammastep.service -g 'Period: ' | ${tail} -1 | ${cut} -d ':' -f6 | ${xargs}))"
              else
              status="$unit_status"
              fi
            '';
            alt = "\${status:-inactive}";
            tooltip = "Gammastep is $status";
          };
          format = "{icon}";
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
          on-click = "${systemctl} --user is-active gammastep && ${systemctl} --user stop gammastep || ${systemctl} --user start gammastep";
        };

        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = jsonOutput "currentplayer" {
            pre = ''
              player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No player active" | ${cut} -d '.' -f1)"
              count="$(${playerctl} -l 2>/dev/null | ${wc} -l)"
              if ((count > 1)); then
                more=" +$((count - 1))"
              else
                more=""
              fi
            '';
            alt = "$player";
            tooltip = "$player ($count available)";
            text = "$more";
          };
          format = "{icon}{}";
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
          on-click = "${playerctld} shift";
          on-click-right = "${playerctld} unshift";
        };

        "custom/player" = {
          exec-if = "${playerctl} status 2>/dev/null";
          exec = ''${playerctl} metadata --format '{"text": "{{title}} - {{artist}}", "alt": "{{status}}", "tooltip": "{{title}} - {{artist}} ({{album}})"}' 2>/dev/null '';
          return-type = "json";
          interval = 2;
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
}
# vim: set ts=2 sw=2 et ai list nu
