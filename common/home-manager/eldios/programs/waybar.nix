{
  pkgs,
  config,
  ...
}: let
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
  jsonOutput = name: {
    pre ? "",
    text ? "",
    tooltip ? "",
    alt ? "",
    class ? "",
    percentage ? "",
  }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
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
in {
  programs.waybar = {
    enable = true;
    systemd.enable = false;

    style = ''
      @import "../omarchy/current/theme/waybar.css";
      @import "../omarchy/overrides/waybar.css";

      * {
        background-color: transparent;
        border: none;
        color: @foreground;
        font-family: "JetBrainsMono Nerd Font", "DejaVu Sans Mono", FontAwesome, sans-serif;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background-color: alpha(@background, 0.92);
        border-bottom: 1px solid alpha(@foreground, 0.12);
        color: @foreground;
      }

      .modules-left {
        margin-left: 8px;
      }

      .modules-right {
        margin-right: 8px;
      }

      #workspaces {
        margin: 0 4px;
      }

      #workspaces button {
        all: initial;
        color: alpha(@foreground, 0.55);
        margin: 0 1.5px;
        min-width: 9px;
        padding: 0 6px;
      }

      #workspaces button.active,
      #workspaces button.focused {
        background-color: alpha(@accent, 0.14);
        color: @accent;
      }

      #workspaces button.empty {
        opacity: 0.45;
      }

      #workspaces button.urgent {
        background-color: @accent;
        color: @background;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #bluetooth,
      #custom-menu,
      #custom-seperator-left,
      #custom-seperator-right,
      #custom-gammastep,
      #custom-currentplayer,
      #custom-player,
      #idle_inhibitor,
      #backlight,
      #disk,
      #cava {
        color: @foreground;
        margin: 0 7px;
        min-width: 12px;
      }

      #custom-menu {
        color: @accent;
        font-size: 16px;
        margin-left: 0;
        margin-right: 9px;
      }

      #custom-currentplayer,
      #custom-player,
      #clock {
        color: @accent;
      }

      #pulseaudio.muted,
      #bluetooth.disabled,
      #bluetooth.off,
      #network.disconnected {
        color: alpha(@foreground, 0.35);
      }

      #battery.critical:not(.charging) {
        background-color: @accent;
        color: @background;
        padding: 0 8px;
      }

      #idle_inhibitor {
        color: alpha(@foreground, 0.55);
      }

      #idle_inhibitor.activated,
      #backlight {
        color: @accent;
      }

      #tray {
        margin-right: 16px;
      }

      tooltip {
        background-color: @background;
        border: 1px solid alpha(@foreground, 0.2);
        padding: 2px;
      }

      tooltip label {
        color: @foreground;
      }
    '';

    settings = {
      primary = {
        mode = "dock";
        layer = "top";
        # position / height / width / margin are NOT set here: they live in the
        # override include below so omarchy-aesthetic-set can change them at
        # runtime (a waybar include cannot override keys set in the main file).
        include = [ "${config.home.homeDirectory}/.config/omarchy/overrides/waybar-config.json" ];

        modules-left = [
          "custom/menu"
          "hyprland/workspaces"
          "niri/workspaces"
          "sway/workspaces"
          "custom/seperator-left"
          "hyprland/window"
        ];

        modules-center = [
          "custom/currentplayer"
          "custom/player"
          "clock"
          "cava"
        ];

        modules-right = [
          "idle_inhibitor"
          "pulseaudio"
          "tray"
          "bluetooth"
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
          format-icons = [" " "▂" "▃" "▄" "▅" "▆" "▇" "█"];
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = ["󰋋" "󰋋" "󰋋"];
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
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          onclick = "";
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 50;
          separate-outputs = true;
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

        bluetooth = {
          format = "󰂯";
          format-connected = "󰂱 {device_alias}";
          format-connected-battery = "󰂱 {device_battery_percentage}%";
          format-disabled = "󰂲";
          format-off = "󰂲";
          tooltip-format = "{controller_alias}\t{status}";
          tooltip-format-connected = "{controller_alias}\t{status}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_battery_percentage}%";
          on-click = "${pkgs.blueman}/bin/blueman-manager";
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
          on-scroll-up = "${pkgs.brightnessctl}/bin/brightnessctl set +5%";
          on-scroll-down = "${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
        };

        disk = {
          interval = 60;
          format = "󰋊 {percentage_used}%";
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
          on-click-left = "omarchy-menu";
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
          format = "{icon}{text}";
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
