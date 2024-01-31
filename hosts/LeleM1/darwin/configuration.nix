{ config, lib, pkgs, nixos-hardware, home-manager, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.eldios = import ../home-manager/home.nix;
      }
    ];
}

# vim: set ts=2 sw=2 et ai list nu
