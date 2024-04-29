{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };

    supportedFilesystems = [ "btrfs" ];

    # latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    # latest non-deprecated Kernel that support ZFS
    #kernelPackages = pkgs.linuxPackages_6_6;

    kernelParams =
    [
      "nohibernate"
    ];

    initrd = {
      supportedFilesystems = [ "btrfs" ];
      kernelModules = [ "uas" "usbcore" "usb_storage" "usbhid" "vfat" "nls_cp437" "nls_iso8859_1" ];

      luks = {
        devices = {
          "K" = {
            device = "/dev/nvme0n1p2"; # << LUKS partition
          };
        };
      };
    };

    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable             = true;
        device             = "nodev";
        efiSupport         = true;
        zfsSupport         = true;
        enableCryptodisk   = true;
        configurationLimit = 14;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
