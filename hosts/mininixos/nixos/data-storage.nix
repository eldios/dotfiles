# RAID + LUKS decryption via crypttab (post-boot, not initrd)

{ pkgs, ... }:

{
  # mdadm config for systemd assembly (not boot.swraid)
  # Using UUID for auto-detection of members (some disks lack stable by-id)
  environment.etc."mdadm.conf".text = ''
    ARRAY /dev/md3 metadata=1.2 name=mininixos:3 UUID=60a81529:6c62153b:1eeae1a0:afa34d8e
  '';

  # Systemd service to assemble RAID post-boot
  systemd.services."mdadm-assemble-md3" = {
    description = "Assemble mdadm RAID array /dev/md3 (RAID6)";
    after = [ "local-fs-pre.target" ];
    before = [ "systemd-cryptsetup@Kdata.service" ];
    wantedBy = [ "multi-user.target" ];

    # Only run if array is not already active
    unitConfig = {
      ConditionPathExists = "!/sys/block/md3/md/array_state";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # Use --uuid to assemble by UUID (auto-detects members)
      ExecStart = "${pkgs.mdadm}/bin/mdadm --assemble --force --uuid=60a81529:6c62153b:1eeae1a0:afa34d8e /dev/md3";
      ExecStop = "${pkgs.mdadm}/bin/mdadm --stop /dev/md3";
    };
  };

  # Post-boot LUKS decryption (systemd-cryptsetup via /etc/crypttab)
  # Kdata depends on RAID assembly, KMa/KMb are independent disks
  environment.etc."crypttab".text = ''
    Kdata /dev/md3 /root/data.key luks,x-systemd.requires=mdadm-assemble-md3.service
    KMa   /dev/disk/by-id/ata-WDC_WD102KFBX-68M95N0_VCG9HBKM-part1 /root/data.key luks
    KMb   /dev/disk/by-id/ata-WDC_WD102KFBX-68M95N0_VCG6MLWN-part1 /root/data.key luks
  '';

  fileSystems."/old_data" = {
    device = "/dev/disk/by-id/dm-name-KMa";
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "noatime"
      "autodefrag"
      "nofail" # Don't fail boot if mount fails
      "x-systemd.requires=systemd-cryptsetup@KMa.service" # Wait for decryption
    ];
  };

  fileSystems."/data" = {
    device = "/dev/mapper/Kdata";
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "noatime"
      "autodefrag"
      "nofail" # Don't fail boot if mount fails
      "x-systemd.requires=systemd-cryptsetup@Kdata.service" # Wait for decryption
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
