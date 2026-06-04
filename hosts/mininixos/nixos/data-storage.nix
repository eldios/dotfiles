{ pkgs, config, ... }:
let
  mdNum       = "3";
  mdDevice    = "md${mdNum}";
  mdName      = "${config.networking.hostName}:${mdNum}";
  mdRaidUuid  = "ae116574:026183e0:036dab17:305da7ad";
  luksName    = "Kdata";
  luksKeyFile = "/root/data.key";
  mountPoint  = "/data";
in
{
  # mdadm config for systemd assembly (not boot.swraid)
  # Using UUID for auto-detection of members (some disks lack stable by-id)
  environment.etc."mdadm.conf".text = ''
    ARRAY /dev/${mdDevice} metadata=1.2 name=${mdName} UUID=${mdRaidUuid}
  '';

  # Systemd service to assemble RAID post-boot
  systemd.services."mdadm-assemble-${mdDevice}" = {
    description = "Assemble mdadm RAID array /dev/${mdDevice} (RAID5)";
    after       = [ "local-fs-pre.target" ];
    before      = [ "systemd-cryptsetup@${luksName}.service" ];
    wantedBy    = [ "multi-user.target" ];

    # Only run if array is not already active
    unitConfig.ConditionPathExists = "!/sys/block/${mdDevice}/md/array_state";

    serviceConfig = {
      Type             = "oneshot";
      RemainAfterExit  = true;
      # Use --uuid to assemble by UUID (auto-detects members)
      ExecStart        = "${pkgs.mdadm}/bin/mdadm --assemble --force --uuid=${mdRaidUuid} /dev/${mdDevice}";
      ExecStop         = "${pkgs.mdadm}/bin/mdadm --stop /dev/${mdDevice}";
    };
  };

  # Post-boot LUKS decryption (systemd-cryptsetup via /etc/crypttab)
  # Kdata depends on RAID assembly, KMa/KMb are independent disks
  environment.etc."crypttab".text = ''
    ${luksName} /dev/${mdDevice} ${luksKeyFile} luks,x-systemd.requires=mdadm-assemble-${mdDevice}.service
  '';

  fileSystems.${mountPoint} = {
    device  = "/dev/mapper/${luksName}";
    fsType  = "btrfs";
    options = [
      "compress=zstd:3"
      "noatime"
      "autodefrag"
      "nofail" # Don't fail boot if mount fails
      "x-systemd.requires=systemd-cryptsetup@${luksName}.service" # Wait for decryption
    ];
  };

  # Scrub /data weekly
  services.btrfs.autoScrub.fileSystems = [ "/data" ];
}

# vim: set ts=2 sw=2 et ai list nu
