{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };

    supportedFilesystems = [ "zfs" ];

    #kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_6_16;
    kernelParams = [
      "nohibernate"
      "zfs.zfs_arc_max=6442856000"
    ];

    initrd = {
      supportedFilesystems = [
        "zfs"
        "btrfs"
      ];
      kernelModules = [
        "uas"
        "usbcore"
        "usb_storage"
        "usbhid"
        "vfat"
        "nls_cp437"
        "nls_iso8859_1"
      ];

      # Support for Yubikey PBA

      luks = {
        yubikeySupport = true;
        cryptoModules = [
          "aes"
          "xts"
          "sha512"
          "sha256"

          "cbc"
          "hmac"
          "rng"
          "encrypted_keys"

          "aes_generic"
          "blowfish"
          "twofish"
          "serpent"
          "lrw"
          "af_alg"
          "algif_skcipher"
        ];

        devices = {
          "K" = {
            device = "/dev/nvme0n1p2"; # << LUKS partition
            preLVM = true;

            # insert this section only if you're using a YubiKey
            yubikey = {
              slot = 2;
              twoFactor = false; # set to true to input password (2FA)

              storage = {
                device = "/dev/nvme0n1p1"; # << SALT /boot partition
                fsType = "vfat";
              };
            };
          };
        };
      };
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
        zfsSupport = true;
        enableCryptodisk = true;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
