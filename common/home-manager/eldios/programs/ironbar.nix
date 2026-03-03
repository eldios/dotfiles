{ pkgs, config, ... }:

let
  colors = config.lib.stylix.colors;
  fontName = config.stylix.fonts.monospace.name;
  fontSize = builtins.toString config.stylix.fonts.sizes.applications;
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
in
{
  home.packages = [ pkgs.ironbar ];

  xdg.configFile."ironbar/config.toml".text = ''
    position = "top"
    height = 34
    anchor_to_edges = true

    # ── Left ──────────────────────────────────────────

    # NixOS menu button
    [[start]]
    type = "label"
    label = "  "
    name = "menu"

    # Workspaces
    [[start]]
    type = "workspaces"
    all_monitors = false
    sort = "added"

    [start.name_map]
    1 = " 1"
    2 = " 2"
    3 = " 3"
    4 = "󰙯 4"
    5 = " 5"
    6 = "6"
    7 = "7"
    8 = "8"
    9 = "9"
    10 = "10"

    # Focused window title
    [[start]]
    type = "focused"
    show_icon = true
    show_title = true
    icon_size = 20

    [start.truncate]
    mode = "end"
    max_length = 50

    # ── Center ────────────────────────────────────────

    # Music / MPRIS
    [[center]]
    type = "music"
    player_type = "mpris"
    format = "{title} - {artist}"
    show_status_icon = true
    icon_size = 20
    on_click_left = "${pkgs.playerctl}/bin/playerctl play-pause"
    on_click_right = "${pkgs.playerctl}/bin/playerctl next"

    [center.truncate]
    mode = "end"
    max_length = 40

    [center.icons]
    play = "󰐊"
    pause = "󰏤"
    prev = "󰒮"
    next = "󰒭"

    # Clock with calendar popup
    [[center]]
    type = "clock"
    format = " %a, %b %d   %H:%M"
    format_popup = "%H:%M:%S"

    # ── Right ─────────────────────────────────────────

    # System info — CPU, RAM, Disk, Net bandwidth
    [[end]]
    type = "sys_info"
    format = [" {cpu_percent:.0}%", " {memory_percent:.0}%", "󰋊 {disk_percent:/@/:.0}%", "󱚺 {net_up}", "󱚶 {net_down}"]
    direction = "horizontal"

    [end.interval]
    cpu = 5
    memory = 10
    disks = 60
    network = 3

    # Tray
    [[end]]
    type = "tray"
    direction = "horizontal"
    icon_size = 20

    # Volume (click opens pavucontrol)
    [[end]]
    type = "volume"
    format = "{icon} {percentage}%"
    max_volume = 100
    on_click_left = "${pavucontrol}"

    [end.icons]
    volume_high = "󰕾"
    volume_medium = "󰖀"
    volume_low = "󰕿"
    muted = "󰝟"

    # Clipboard manager
    [[end]]
    type = "clipboard"
    max_items = 10
    icon_size = 20

    # Network
    [[end]]
    type = "network_manager"
    icon_size = 20

    # Bluetooth
    [[end]]
    type = "bluetooth"
    icon_size = 20

    [end.format]
    not_found = "󰂲"
    disabled = "󰂲 Off"
    enabled = "󰂯 On"
    connected = "󰂱 {device_alias}"
    connected_battery = "󰂱 {device_alias} {device_battery_percent}%"

    # Keyboard (caps lock indicator)
    [[end]]
    type = "keyboard"
    show_caps = true
    show_num = false
    show_scroll = false
    show_layout = false

    # Battery (requires UPower — enabled in desktop-gui.nix)
    [[end]]
    type = "battery"
    format = "{icon} {percentage}%"
  '';

  xdg.configFile."ironbar/style.css".text = ''
    /* Ironbar Theme - Stylix Integrated */

    * {
        font-family: "${fontName}", FontAwesome;
        font-size: ${fontSize}px;
    }

    #bar {
        background-color: #${colors.base00};
        color: #${colors.base05};
        border-bottom: 2px solid #${colors.base02};
    }

    .widget {
        padding: 0 6px;
    }

    /* NixOS menu button */
    #menu {
        color: #${colors.base0D};
        font-size: 16px;
        padding: 0 10px 0 6px;
    }

    #menu:hover {
        color: #${colors.base0E};
    }

    /* Workspaces */
    .workspaces .item {
        padding: 0 8px;
        margin: 0 1px;
        color: #${colors.base04};
        background-color: transparent;
        border-radius: 6px;
        transition: all 0.3s ease;
    }

    .workspaces .item.focused {
        color: #${colors.base0B};
        background-color: #${colors.base01};
        border: 1px solid #${colors.base0B};
    }

    .workspaces .item.visible {
        color: #${colors.base0D};
        background-color: #${colors.base02};
    }

    .workspaces .item.urgent {
        color: #${colors.base00};
        background-color: #${colors.base0A};
    }

    .workspaces .item:hover {
        background-color: #${colors.base01};
    }

    /* Focused window */
    .focused {
        padding: 0 8px;
        color: #${colors.base04};
        font-style: italic;
    }

    /* Clock */
    .clock {
        font-weight: bold;
        padding: 0 12px;
        color: #${colors.base0E};
    }

    /* Music / MPRIS */
    .music {
        padding: 0 10px;
        color: #${colors.base0B};
    }

    /* System info */
    .sys_info {
        padding: 0 4px;
        color: #${colors.base04};
    }

    .sys_info label {
        margin: 0 3px;
        padding: 0 2px;
    }

    /* Tray */
    .tray .item {
        padding: 0 4px;
    }

    /* Volume */
    .volume {
        padding: 0 6px;
    }

    .volume.muted {
        color: #${colors.base03};
    }

    /* Clipboard */
    .clipboard {
        padding: 0 6px;
    }

    /* Network */
    .network_manager {
        padding: 0 6px;
    }

    /* Bluetooth */
    .bluetooth {
        padding: 0 6px;
    }

    /* Keyboard */
    .keyboard {
        padding: 0 6px;
        color: #${colors.base04};
    }

    /* Battery */
    .battery {
        padding: 0 6px;
    }

    .battery.charging {
        color: #${colors.base0C};
    }

    .battery.critical {
        color: #${colors.base00};
        background-color: #${colors.base08};
        border-radius: 4px;
        padding: 0 6px;
    }

    /* Popups */
    .popup {
        background-color: #${colors.base00};
        color: #${colors.base05};
        border: 1px solid #${colors.base03};
        border-radius: 8px;
        padding: 12px;
    }

    .popup button {
        background-color: #${colors.base01};
        color: #${colors.base05};
        border: none;
        border-radius: 4px;
        padding: 4px 8px;
    }

    .popup button:hover {
        background-color: #${colors.base02};
    }

    /* Tooltips */
    tooltip {
        background-color: #${colors.base01};
        color: #${colors.base05};
        border: 1px solid #${colors.base03};
        border-radius: 8px;
        padding: 8px;
    }

    /* Sliders (volume popup, brightness) */
    scale trough {
        background-color: #${colors.base01};
        border-radius: 4px;
        min-height: 8px;
    }

    scale highlight {
        background-color: #${colors.base0D};
        border-radius: 4px;
    }

    scale slider {
        background-color: #${colors.base05};
        border-radius: 50%;
        min-width: 12px;
        min-height: 12px;
    }
  '';
}
# vim: set ts=2 sw=2 et ai list nu
