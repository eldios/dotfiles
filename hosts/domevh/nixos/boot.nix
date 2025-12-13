{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };

    supportedFilesystems = [ "btrfs" ];

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "console=tty1"
      "console=ttyS0,115200" # OVH serial console access
    ];

    initrd = {
      supportedFilesystems = [ "btrfs" ];
      kernelModules = [
        "virtio_pci"
        "virtio_scsi"
        "virtio_blk"
        "virtio_net"
      ];
    };

    loader = {
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
