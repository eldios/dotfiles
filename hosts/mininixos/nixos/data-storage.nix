# data RAID disks

{
  boot.initrd.luks.devices = {
    "KMa" = {
      device = "/dev/sdc1";
      keyFile = "/root/data.key";
      allowDiscards = true;
    };
    "KMb" = {
      device = "/dev/sdd1";
      keyFile = "/root/data.key";
      allowDiscards = true;
    };
  };

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/5c550c2f-ea48-422d-af69-459eeba5c822";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "nodiratime"
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
