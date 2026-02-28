# Boot configuration for mininixos (BTRFS + LUKS + Yubikey PBA)
#
# LUKS device "K" is declared by disko.nix (device path, allowDiscards).
# This file adds Yubikey PBA settings on top via NixOS module merging.
# Password fallback is keyslot 0 (set manually during LUKS format).
# Yubikey challenge-response is keyslot 1 (added manually via luksAddKey).

{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };

    supportedFilesystems = [ "btrfs" ];

    # BTRFS is in-kernel - no ZFS compat constraint, use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "nohibernate"
    ];

    initrd = {
      supportedFilesystems = [ "btrfs" ];
      kernelModules = [
        "uas"
        "usbcore"
        "usb_storage"
        "usbhid"
        "vfat"
        "nls_cp437"
        "nls_iso8859_1"
      ];

      # Yubikey PBA - merged with disko's LUKS device "K" declaration
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
          # disko sets: device, allowDiscards
          # we add: preLVM, yubikey
          "K" = {
            preLVM = true;

            yubikey = {
              slot = 2;
              twoFactor = false; # Yubikey-only; password is separate LUKS keyslot

              storage = {
                device = "/dev/nvme1n1p2"; # ESP on new 4TB disk (salt storage)
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
        enableCryptodisk = true;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
