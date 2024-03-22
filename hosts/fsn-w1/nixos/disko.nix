{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x500a075117572b7c";
        content = {
          type = "gpt";
          partitions = {
            boot1 = {
              name = "boot1";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot1";
              };
            };
            zfs1 = {
              name = "zfs1";
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      sdb = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x500a0751174454f0";
        content = {
          type = "gpt";
          partitions = {
            boot2 = {
              name = "boot2";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot2";
              };
            };
            zfs2 = {
              name = "zfs2";
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "mirror";
        rootFsOptions = {
          canmount = "off";
        };

        datasets = {
          os = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
          };
          var = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var";
          };
          nix = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
          data = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/data";
          };
          home = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}
