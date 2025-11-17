{
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  nixos-hardware,
  home-manager,
  ...
}:

{
  imports = [
    # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-gpu-nvidia
    nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../../../common/nixos/sops.nix

    ../../../common/nixos/locale.nix
    ../../../common/nixos/locale_gui.nix

    ../../../common/nixos/users.nix
    ../../../common/nixos/system.nix

    ../../../common/nixos/nix-cache.nix

    ../../../common/nixos/programs/neovim.nix

    ../../../common/nixos/virtualisation.nix

    ./hardware-configuration.nix

    ./boot.nix
    ./system.nix
    ./network.nix
    ./users.nix

    home-manager.nixosModules.home-manager
    {
      home-manager.backupFileExtension = "hm-backup";

      home-manager.users.eldios = import ../home-manager/home.nix;

      home-manager.sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.stylix.homeModules.stylix
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
