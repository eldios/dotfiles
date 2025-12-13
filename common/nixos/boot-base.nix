# Common boot configuration shared across all hosts
# Host-specific boot.nix files should import this and add their unique settings
{ pkgs, lib, ... }:
{
  boot = {
    kernel.sysctl = {
      "vm.swappiness" = lib.mkDefault 5;
    };

    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    loader = {
      efi = {
        efiSysMountPoint = lib.mkDefault "/boot";
      };
      grub = {
        enable = lib.mkDefault true;
        device = lib.mkDefault "nodev";
        efiSupport = lib.mkDefault true;
        configurationLimit = lib.mkDefault 14;
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
