{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "zNix/root/os";
    fsType = "zfs";
  };

  fileSystems."/var" = {
    device = "zNix/root/var";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zNix/root/nix";
    fsType = "zfs";
  };

  fileSystems."/data" = {
    device = "zNix/persist/data";
    fsType = "zfs";
  };

  fileSystems."/etc/nixos" = {
    device = "zNix/persist/nixos";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zNix/persist/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6FA0-A3DC";
    fsType = "vfat";
  };

  environment.etc.crypttab = {
    enable = true;
    text = ''
      KMb /dev/disk/by-id/wwn-0x5000cca0b0c4510c-part1 /root/data.key luks
      KMc /dev/disk/by-id/wwn-0x5000cca0b0c303d6-part1 /root/data.key luks
    '';
  };

  fileSystems."/data/10TB" = {
    mountPoint = "/data/10TB";
    device = "/dev/disk/by-label/10TB";
    fsType = "btrfs";
    depends = [
      "/data"
    ];
    neededForBoot = false;
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
