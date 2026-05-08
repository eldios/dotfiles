{ lib, ...}:
{
  disko.devices = {
    disk = {
      # Distinct disk key from lele9iyoga's `sda` to avoid any chance of
      # cross-host disko confusion when both flake outputs are evaluated.
      nvme0n1 = {
        type = "disk";
        # TODO: replace with actual L13 NVMe serial before re-running
        # disko on this host. Current value is a placeholder distinct
        # from lele9iyoga's drive ID so an accidental disko apply here
        # cannot match (and wipe) the 9i's disk.
        device = lib.mkDefault "/dev/disk/by-id/nvme-LELEL13YOGA-PLACEHOLDER-REPLACE-WITH-REAL-SERIAL";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "data";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # overwrite existing partitions
                  subvolumes = {
                    "/os" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/data" = {
                      mountpoint = "/data";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var" = {
                      mountpoint = "/var";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
