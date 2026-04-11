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
      # Workaround Ryzen 5000U (Cezanne/Barcelo) TSC desync + mt7921e PCIe
      # instability: without this, deep C-states cause TSC warp between CPUs
      # and mt7921e chip reset loops (driver own failed).
      "processor.max_cstate=1"
      # Passive P-state: avoids aggressive freq transitions that interact
      # with TSC desync on this SoC. Replaces nixos-hardware common-cpu-amd-pstate.
      "amd_pstate=passive"
      # S3 deep sleep instead of s2idle: s2idle requires deep C-states to work
      # but max_cstate=1 blocks them, causing freeze on resume. S3 is hardware
      # suspend managed by firmware and works with max_cstate=1. mt7921e WiFi
      # unloaded before suspend via systemd hook in system.nix.
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
