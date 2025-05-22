{ lib, ... }:
{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/usb-iODD_vHDD_Gadget_0_M242A00001432-0:1";
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

      # IMPORTANT FOR WINDOWS VM: The disk intended for the Windows 11 VM (currently placeholder '/dev/disk/by-id/CHANGE_WITH_CORRECT_ID')
      # should NOT be configured or managed by Disko here. It needs to be exclusively available for passthrough to the VM.
      # Ensure that no entry in this 'disko.devices.disk' block attempts to format or partition it.
    };
  };
}
