{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };

    supportedFilesystems = [ "zfs" "btrfs" ];

    #kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_6_7;
    kernelParams =
    [
      "nohibernate"
      "zfs.zfs_arc_max=6442856000"
    ];

    initrd = {
      supportedFilesystems = [ "zfs" "btrfs" ];
      kernelModules = [ "uas" "usbcore" "nvme" "usb_storage" "usbhid" "vfat" "nls_cp437" "nls_iso8859_1" ];
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
      };
      grub = {
        enable           = true;
        efiSupport       = true;
        efiInstallAsRemovable = false;
        zfsSupport       = true;
        enableCryptodisk = true;
        mirroredBoots    = [
          {
            devices = [ "nodev" ];
            path = "/boot1";
            efiSysMountPoint = "/boot1";
          }
          {
            devices = [ "nodev" ];
            path = "/boot2";
            efiSysMountPoint = "/boot2";
          }
        ];
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
