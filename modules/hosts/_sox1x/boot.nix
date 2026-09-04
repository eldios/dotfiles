{pkgs, ...}: {
  boot = {
    supportedFilesystems = [
      "btrfs"
      "zfs"
    ];

    # hostId is stable and the pool never moves between machines, so the
    # initrd can import it without -f (default from 26.11 on).
    zfs.forceImportRoot = false;

    # Root-on-ZFS: stay on the default LTS kernel, the one ZFS reliably
    # supports (linuxPackages_latest often has no compatible ZFS build).
    kernelPackages = pkgs.linuxPackages;
    kernelParams = [
      "nohibernate"
      "zfs.zfs_arc_max=6442856000"
    ];

    initrd = {
      supportedFilesystems = ["zfs"];
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
        devices = {
          "K" = {
            device = "/dev/nvme0n1p2"; # << LUKS partition
          };
        };
      };
    };

    loader = {
      efi.canTouchEfiVariables = true;
      grub.enableCryptodisk = true;
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

