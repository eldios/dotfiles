{ pkgs, lib, ... }:
{
  # swayosd: on-screen overlay for volume/brightness/capslock events.
  # Matches Omarchy upstream's default OSD stack.
  home.packages = [ pkgs.swayosd ];

  # systemd user service that runs swayosd-server, autostarting at
  # graphical-session.target with auto-restart on failure.
  systemd.user.services.swayosd-server = {
    Unit = {
      Description = "swayosd OSD daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      # Wayland-only client; skip in i3/X11 sessions.
      ConditionEnvironment = "XDG_SESSION_TYPE=wayland";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
# vim: set ts=2 sw=2 et ai list nu
