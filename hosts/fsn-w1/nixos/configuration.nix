{ nixos-hardware, home-manager, ... }:

{
  imports =
    [
      # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
      nixos-hardware.nixosModules.common-cpu-intel

      ../../../common/nixos/locale.nix
      ../../../common/nixos/users.nix
      ../../../common/nixos/system.nix

      ../../../common/nixos/virtualisation.nix

      #./hardware-configuration.nix
      ./disko.nix

      ./boot.nix
      ./system.nix
      ./network.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.users.eldios = import ../home-manager/home.nix;

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
}

# vim: set ts=2 sw=2 et ai list nu
