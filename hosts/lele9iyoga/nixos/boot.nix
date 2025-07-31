{ config, pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };
    kernelModules = [
      "kvm-intel"
      "v4l2loopback"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    supportedFilesystems = [ "btrfs" ];

    # latest kernel
    #kernelPackages = pkgs.linuxPackages_latest;
    # latest non-deprecated Kernel that support ZFS
    kernelPackages = pkgs.linuxPackages_6_15;

    kernelParams = [
      "nohibernate"
    ];

    initrd = {
      supportedFilesystems = [ "btrfs" ];
      kernelModules = [ ];
      availableKernelModules = [
        "nls_cp437"
        "nls_iso8859_1"
        "nvme"
        "sd_mod"
        "sr_mod"
        "thunderbolt"
        "uas"
        "usb_storage"
        "usbcore"
        "usbhid"
        "vfat"
        "xhci_pci"
      ];
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        zfsSupport = true;
        enableCryptodisk = true;
        configurationLimit = 14;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
