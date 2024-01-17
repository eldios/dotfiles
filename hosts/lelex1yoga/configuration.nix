{ config, lib, pkgs, nixos-hardware, home-manager, ... }:

{
  imports =
    [
      # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
      #nixos-hardware.nixosModules.lenovo-thinkpad-x1-yoga-7th-gen
      ./hardware-configuration.nix
      ./system.nix
      ./boot.nix
      ./network.nix
      ./users.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.eldios = import ./home.nix;

        # Optionally, use home-manager.extraSpecialArgs to pass
        # arguments to home.nix
      }
    ];
}

# vim: set ts=2 sw=2 et ai list nu
