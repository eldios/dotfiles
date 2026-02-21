{
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  nixos-hardware,
  home-manager,
  claude-code-overlay,
  gemini-cli-nix,
  ...
}:

{
  # Apply overlays here to avoid warning with home-manager.useGlobalPkgs
  nixpkgs.overlays = [
    (import ../../../common/nixos/overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
    claude-code-overlay.overlays.default
    gemini-cli-nix.overlays.default
    (import ../../../common/nixos/overlays/gitbutler.nix)
  ];

  imports = [
    # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    # mininixos
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-gpu-amd

    nixos-hardware.nixosModules.common-pc-ssd

    ../../../common/nixos/sops.nix

    ../../../common/nixos/locale.nix

    ../../../common/nixos/users.nix
    ../../../common/nixos/system.nix

    ../../../common/nixos/nix-cache.nix

    ../../../common/nixos/programs/neovim.nix

    ../../../common/nixos/virtualisation.nix

    ./hardware-configuration.nix

    ./boot.nix
    ./system.nix
    ./network.nix
    ./data-storage.nix
    ./libvirt-vms.nix

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
