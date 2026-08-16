{
  # lele8845ace workstation: dual external monitors.
  # Declarative so a config reload reapplies the layout instead of
  # reverting to defaults.
  desktop.hyprland.monitors = [
    "HDMI-A-1,2560x1440,0x0,1"
    "DP-2,3440x1440,2560x0,1"
    ",preferred,auto,1" # fallback for any other connected output
  ];
}
# vim: set ts=2 sw=2 et ai list nu
