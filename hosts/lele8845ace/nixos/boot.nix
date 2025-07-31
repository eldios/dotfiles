{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };
    kernelModules = [
      "kvm-amd"
      "v4l2loopback"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    supportedFilesystems = [
      "btrfs"
      "ntfs"
    ];

    # latest kernel
    #kernelPackages = pkgs.linuxPackages_latest;
    #kernelPackages = pkgs.linuxPackages_zen;
    # latest non-deprecated Kernel that support ZFS
    kernelPackages = pkgs.linuxPackages_6_15;

    kernelParams = [
      "nohibernate"
      "acpi_enforce_resources=lax"
      #"snd_intel_dspcfg.dsp_driver=1" # if 3 and 1 don't work move to Pulseaudio
    ];

    #kernelPatches = [{
    #  name = "NCT6775 driver";
    #  patch = null;
    #  extraStructuredConfig = with lib.kernel; {
    #    I2C_NCT6775 = lib.mkForce yes;
    #  };
    #}];

    initrd = {
      supportedFilesystems = [ "btrfs" ];
      kernelModules = [ "amdgpu" ];
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
