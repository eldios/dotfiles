{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };

    supportedFilesystems = [ "zfs" ];

    #kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_6_7;
    kernelParams =
    [
      "net.ifnames=0"
      "nohibernate"
      "zfs.zfs_arc_max=6442856000"
    ];

    initrd = {
      supportedFilesystems = [ "zfs" ];
      kernelModules = [ "virtio-scsi" "uas" "usbcore" "nvme" "usb_storage" "usbhid" "vfat" "nls_cp437" "nls_iso8859_1" ];
    };

    loader = {
      efi = {
        canTouchEfiVariables = false;
      };
      grub = {
        enable           = true;
        forceInstall     = true;
        zfsSupport       = true;
        efiSupport       = true;
        efiInstallAsRemovable = true;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
