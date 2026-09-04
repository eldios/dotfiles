{config, ...}: {
  boot = {
    kernelModules = [
      "kvm-intel"
      "v4l2loopback"
    ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    supportedFilesystems = ["btrfs"];

    kernelParams = [
      "nohibernate"
    ];

    initrd = {
      # systemd-based initrd: cleaner LUKS unlock UI, faster boot,
      # enables future systemd-cryptenroll/TPM2 unlock paths.
      systemd.enable = true;

      supportedFilesystems = ["btrfs"];
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
      efi.canTouchEfiVariables = true;
      grub.enableCryptodisk = true;
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

