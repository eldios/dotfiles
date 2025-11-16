# data RAID disks

{
  boot.initrd.luks.devices = {
    "Kdata" = {
      device = "/dev/md3";
      keyFile = "/root/data.key";
    };
  };

  boot.swraid = {
    enable = true;
    mdadmConf = ''
      ARRAY /dev/md3 devices=/dev/disk/by-id/wwn-0x5000c500ea465078,/dev/disk/by-id/wwn-0x5000c50000465a5a,/dev/disk/by-id/wwn-0x500000005a5aff0c
    '';
  };

  fileSystems."/data" = {
    device = "/dev/mapper/Kdata"; # Your new UUID
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "noatime"
      "autodefrag"
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
