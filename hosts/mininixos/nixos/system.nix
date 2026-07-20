{ lib, ... }:
{
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Docker data on dedicated 1.8TB disk
  virtualisation.docker.daemon.settings = {
    data-root = "/srv/docker";
  };

  # dockerd must wait for its data-root AND every bind-mount source before
  # starting, else a container binds an unmounted path: postgres ran initdb
  # on an empty /data while the RAID was still assembling, shadowing the real
  # Immich DB (2026-06-22). /data added to prevent a repeat.
  systemd.services.docker.unitConfig.RequiresMountsFor = "/srv/docker /srv/containers /data";

  # Hardware watchdog: auto-reboot if the host hard-freezes (a btrfs commit
  # stall wedged it 2026-06-22 and needed a manual power-cycle). /dev/watchdog exists.
  systemd.watchdog.runtimeTime = "30s";

  services.btrfs.autoScrub = {
    enable = true;
    # Not "weekly": that is Mon 00:00, the same instant as nix-gc.dates =
    # "weekly", and the combined scrub+GC I/O peak on the root NVMe
    # correlates with both 990 PRO controller dropouts (Jun 28, Jul 20).
    interval = "Sat *-*-* 04:00:00";
    fileSystems = [ "/" ]; # scrubs entire BTRFS filesystem including all subvolumes
    # /srv/docker scrub is in srv-storage.nix
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
