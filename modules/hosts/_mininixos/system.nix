{lib, ...}: {
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = false;
  };

  # Docker data on dedicated 1.8TB disk
  virtualisation.docker.daemon.settings = {
    data-root = "/srv/docker";
    # Networks without an explicit subnet get a /28 from here. The built-in
    # pools hand out /16 and then /20 slices of 192.168.0.0/16, which
    # overlap the LAN ranges; compose networks pin theirs in 172.16.0.0/16.
    default-address-pools = [
      {
        base = "172.17.0.0/16";
        size = 28;
      }
    ];
  };

  # dockerd must wait for its data-root AND every bind-mount source before
  # starting, else a container binds an unmounted path: postgres ran initdb
  # on an empty /data while the RAID was still assembling, shadowing the real
  # Immich DB (2026-06-22). /data added to prevent a repeat.
  systemd.services.docker.unitConfig.RequiresMountsFor = "/srv/docker /srv/containers /data";

  # Hardware watchdog: auto-reboot if the host hard-freezes (a btrfs commit
  # stall wedged it 2026-06-22 and needed a manual power-cycle). /dev/watchdog exists.
  systemd.settings.Manager.RuntimeWatchdogSec = "30s";

  services.btrfs.autoScrub = {
    enable = true;
    # Not "weekly": that is Mon 00:00, the same instant as nix-gc.dates =
    # "weekly", and the combined scrub+GC I/O peak on the root NVMe
    # correlates with both 990 PRO controller dropouts (Jun 28, Jul 20).
    interval = "Sat *-*-* 04:00:00";
    fileSystems = ["/"]; # scrubs entire BTRFS filesystem including all subvolumes
    # /srv/docker scrub is in srv-storage.nix
  };

  # The module gives every filesystem the same OnCalendar: four parallel
  # scrubs saturated every HDD for 14 hours and preceded the 2026-10-24
  # freeze. One filesystem per night; /data (RAID5) and /archive take over
  # 12 hours each, so they run monthly (the period btrfs-scrub(8)
  # recommends) in different weeks. The module's AccuracySec=1d lets a run
  # slip by up to a day; 1h keeps the nights apart.
  systemd.timers =
    lib.mapAttrs (_: when: {
      timerConfig = {
        OnCalendar = lib.mkForce when;
        AccuracySec = lib.mkForce "1h";
      };
    }) {
      "btrfs-scrub--" = "Sat *-*-* 04:00:00";
      "btrfs-scrub-srv-docker" = "Sun *-*-* 04:00:00";
      "btrfs-scrub-data" = "Tue *-*-01..07 01:00:00";
      "btrfs-scrub-archive" = "Thu *-*-15..21 01:00:00";
    };

  # Compressed swap in RAM - safety net for OOM
  zramSwap = {
    enable = true;
    memoryPercent = 10; # ~9GB compressed swap - host is mostly hypervisor
    algorithm = "zstd";
  };

  # Disable CoW for VM disk images (qcow2/raw) - prevents write amplification
  # chattr +C is per-file/directory, not a mount option
  systemd.tmpfiles.rules = [
    "h /vms - - - - +C"
  ];
}
# vim: set ts=2 sw=2 et ai list nu

