{ lib, ... }:
{
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # BTRFS storage driver (matching lele8845ace pattern)
  virtualisation.docker.storageDriver = "btrfs";

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ]; # scrubs entire BTRFS filesystem including all subvolumes
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
