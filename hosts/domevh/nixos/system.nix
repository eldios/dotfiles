{ lib, ... }:
{
  system = {
    stateVersion = "25.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = false;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Compressed swap in RAM - safety net for OOM on VMs
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # QEMU guest agent for OVH management
  services.qemuGuest.enable = true;

  # QEMU VMs don't support SMART - disable to prevent service failure
  services.smartd.enable = lib.mkForce false;

  # Enable btrfs scrubbing
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
  };
}

# vim: set ts=2 sw=2 et ai list nu
