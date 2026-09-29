# Nightly run of homelab-compose's tools/auto-bump.py: moves the allowlisted
# image pins, pushes as ops, redeploys and reports to Matrix. Scheduled after
# the buzz-agent release workflow (03:17 UTC) has had time to publish.
{
  config,
  pkgs,
  ...
}: {
  systemd.services.homelab-auto-bump = {
    description = "Move allowlisted image pins in homelab-compose and redeploy";
    after = ["network-online.target" "docker.service"];
    wants = ["network-online.target"];
    path = [config.virtualisation.docker.package pkgs.git pkgs.python3 pkgs.skopeo];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/srv/containers/homelab-compose";
      ExecStart = "${pkgs.python3}/bin/python3 /srv/containers/homelab-compose/tools/auto-bump.py";
      TimeoutStartSec = "1h";
    };
  };

  systemd.timers.homelab-auto-bump = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 06:30:00";
      RandomizedDelaySec = "10m";
      # A missed night is skipped: the next run catches up anyway.
      Persistent = false;
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

