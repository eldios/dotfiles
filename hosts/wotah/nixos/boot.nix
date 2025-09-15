{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };
    kernelModules = [
      "kvm-amd"
      "nvidia"
    ];
    #extraModulePackages = with config.boot.kernelPackages; [ ];

    supportedFilesystems = [
      "btrfs"
      "exfat"
      "zfs"
    ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "nohibernate"
      #"snd_intel_dspcfg.dsp_driver=1" # if 3 and 1 don't work move to Pulseaudio
      "amd_iommu=on"
      "iommu=pt"
    ];

    initrd = {
      supportedFilesystems = [
        "btrfs"
        "exfat"
      ];
      kernelModules = [ "nvidia" ];
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
