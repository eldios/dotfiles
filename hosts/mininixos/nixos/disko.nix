# BTRFS + LUKS disk layout for mininixos (nvme1n1, 4TB Samsung 990 PRO)
#
# Partition scheme:
#   p1: 1M   BIOS boot (EF02)
#   p2: 1G   ESP/vfat  -> /boot (also stores Yubikey HMAC salt)
#   p3: rest  LUKS "K" -> BTRFS with subvolumes
#
# Yubikey PBA settings are in boot.nix (merged via NixOS module system).
# disko handles partition layout + LUKS device declaration + BTRFS subvolumes.

{ lib, ... }:
{
  disko.devices = {
    disk = {
      nvme1 = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_4TB_S7DPNU0Y802410D";
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
                mountOptions = [ "noatime" "nodiratime" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "K";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-L" "mininixos" "-f" ];
                  subvolumes = {
                    "/os" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" "nodiratime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd:6" "noatime" "nodiratime" ];
                    };
                    "/var" = {
                      mountpoint = "/var";
                      mountOptions = [ "compress=zstd" "noatime" "nodiratime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" "nodiratime" "commit=60" ];
                    };
                    "/vms" = {
                      mountpoint = "/vms";
                      mountOptions = [ "compress=zstd" "noatime" "nodiratime" ];
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

# vim: set ts=2 sw=2 et ai list nu
