{ config, lib, pkgs, nixos-hardware, home-manager, ... }:

{
  imports =
    [
      # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
      nixos-hardware.nixosModules.common-cpu-amd
      nixos-hardware.nixosModules.common-gpu-amd
      nixos-hardware.nixosModules.common-pc-ssd

      ./hardware-configuration.nix
      ./system.nix
      ./boot.nix
      ./network.nix
      ./users.nix
      ./locale.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.eldios = import ../home-manager/home.nix;

        # Optionally, use home-manager.extraSpecialArgs to pass
        # arguments to home.nix
      }
    ];
}

# vim: set ts=2 sw=2 et ai list nu
