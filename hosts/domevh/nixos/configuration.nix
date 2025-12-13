{
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  ...
}:

{
  # Apply overlays here to avoid warning with home-manager.useGlobalPkgs
  nixpkgs.overlays = [
    (import ../../../common/nixos/overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
    (import ../../../common/nixos/overlays/custom-packages.nix)
  ];

  imports = [
    # Common NixOS modules
    ../../../common/nixos/sops.nix
    ../../../common/nixos/locale.nix
    ../../../common/nixos/users.nix
    ../../../common/nixos/system.nix
    ../../../common/nixos/nix-cache.nix
    ../../../common/nixos/programs/neovim.nix
    ../../../common/nixos/virtualisation.nix

    # Host-specific configs
    ./disko.nix
    ./boot.nix
    ./system.nix
    ./network.nix
    ./users.nix

    # Home-manager integration
    home-manager.nixosModules.home-manager
    {
      home-manager.backupFileExtension = "hm-backup";
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
          ;
      };
    }
  ];
}

# vim: set ts=2 sw=2 et ai list nu
