{ inputs, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, ... }:

{
  # Apply overlays here to avoid warning with home-manager.useGlobalPkgs
  nixpkgs.overlays = [
    (import ../../../common/nixos/overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
    (import ../../../common/nixos/overlays/custom-packages.nix)
  ];

  imports =
    [
      # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
      nixos-hardware.nixosModules.intel-nuc-8i7beh
      nixos-hardware.nixosModules.common-cpu-intel

      ../../../common/nixos/sops.nix

      ../../../common/nixos/locale.nix

      ../../../common/nixos/users.nix
      ../../../common/nixos/system.nix

      ../../../common/nixos/programs/neovim.nix

      ../../../common/nixos/virtualisation.nix

      ./hardware-configuration.nix

      ./boot.nix
      ./system.nix
      ./network.nix

      home-manager.nixosModules.home-manager
      {
        home-manager.users.eldios = import ../home-manager/home.nix;

        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
        ];

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit
            inputs
            nixpkgs
            nixpkgs-unstable
            home-manager
            nixos-hardware
            ;
        };
      }
    ];
}

# vim: set ts=2 sw=2 et ai list nu
