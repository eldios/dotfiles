{ config, pkgs, ... }:
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

    supportedFilesystems = [ "btrfs" ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "nohibernate"
      # Passive P-state: avoids aggressive freq transitions that interact
      # with TSC desync on this SoC. Replaces nixos-hardware common-cpu-amd-pstate.
      "amd_pstate=passive"
      # Use S3 deep sleep: s2idle is broken on Barcelo (fails to resume),
      # especially combined with max_cstate=1 which blocks the deep C-states
      # s2idle needs. mt7921e WiFi error -110 on S3 resume is handled by
      # systemd suspend hook that unloads/reloads the module.
      "mem_sleep_default=deep"
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
