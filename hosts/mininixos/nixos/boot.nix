# Boot configuration for mininixos (BTRFS + LUKS)
#
# LUKS device "M" is declared by disko.nix (device path, allowDiscards).
# systemd stage 1 unlocks it with the passphrase in LUKS keyslot 0. Keyslot 2
# still holds the legacy Yubikey challenge-response secret (unused by systemd
# stage 1); re-enroll the key with `systemd-cryptenroll --fido2-device=auto`.

{ pkgs, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5;
    };

    supportedFilesystems = [ "btrfs" ];

    # Must track linuxPackages_latest: the stable series (6.18) fails to
    # assemble the /data RAID5 (md rejects a valid superblock, -EINVAL).
    # Freeze risk is handled via autodefrag removal + watchdog instead.
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "nohibernate"
      "amdgpu.runpm=0" # disable runtime PM — headless server, GPU must stay awake for Ollama
      "pcie_aspm=off" # root NVMe (990 PRO) drops off the PCIe bus under ASPM L1, killing the root fs
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

      luks = {
        cryptoModules = [
          "aes"
          "xts"
          "sha512"
          "sha256"

          "cbc"
          "hmac"
          "rng"
          "encrypted_keys"

          "blowfish"
          "twofish"
          "serpent"
          "lrw"
          "af_alg"
          "algif_skcipher"
        ];

        devices = {
          # disko sets: device, allowDiscards
          "M" = {
            preLVM = true;
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
        configurationLimit = 3;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
