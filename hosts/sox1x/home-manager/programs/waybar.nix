{ config, pkgs, ... }:

let
    # Dependencies
    cat = "${pkgs.coreutils}/bin/cat";
    cut = "${pkgs.coreutils}/bin/cut";
    find = "${pkgs.findutils}/bin/find";
    grep = "${pkgs.gnugrep}/bin/grep";
    pgrep = "${pkgs.procps}/bin/pgrep";
    tail = "${pkgs.coreutils}/bin/tail";
    wc = "${pkgs.coreutils}/bin/wc";
    xargs = "${pkgs.findutils}/bin/xargs";

    jq = "${pkgs.jq}/bin/jq";
    systemctl = "${pkgs.systemd}/bin/systemctl";
    journalctl = "${pkgs.systemd}/bin/journalctl";
    playerctl = "${pkgs.playerctl}/bin/playerctl";
    playerctld = "${pkgs.playerctl}/bin/playerctld";
    pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";

    # Function to simplify making waybar outputs
    jsonOutput = name: { pre ? "", text ? "", tooltip ? "", alt ? "", class ? "", percentage ? "" }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
      set -euo pipefail
      ${pre}
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
          "custom/menu"
          "sway/workspaces"
          "custom/seperator-left"
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
          # on-click = "mode";
          tooltip-format = ''
          <tt><small>{calendar}</small></tt>
          '';        # TODO: Implement gcal: {gcal --starting-day=1 | sed -e 's|<|\[|g' -e 's|>|\]|g}
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
          on-scroll-up = "light -A 5";
          on-scroll-down = "light -U 5";
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
          return-type = "json";
          exec = jsonOutput "menu" {
            text = "";
            tooltip = ''$(${cat} /etc/os-release | ${grep} PRETTY_NAME | ${cut} -d '"' -f2)'';
          };
          on-click-left = "rofi -S drun -x 10 -y 10 -W 25% -H 60%";
          on-click-right = "swaymsg scratchpad show";
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
} # EOF
# vim: set ts=2 sw=2 et ai list nu
