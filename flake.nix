{
  description = "Lele's nix conf - for macOS and nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # base imports
    utils.url = "github:numtide/flake-utils";

    # additional utils
    nixos-hardware.url = "github:nixos/nixos-hardware";
    xremap.url = "github:xremap/nix-flake";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/eldios/secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs =
    { nixpkgs
    , nixpkgs-unstable
    , nixpkgs-darwin
    , home-manager
    , darwin
    , nixos-hardware
    , disko
    , sops-nix
    , xremap
    , ...
    } @ inputs:
    let

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      # Define common specialArgs for nixosConfigurations and homeConfigurations
      commonSpecialArgs = {
        inherit
          inputs
          nixpkgs
          nixpkgs-unstable
          nixpkgs-darwin
          home-manager
          nixos-hardware
          disko
          sops-nix
          xremap
          ;
      };

      # Lele's Yoga9i
      nixosConfigurations.lele9iyoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/lele9iyoga/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

      # Minis NUC
      nixosConfigurations.mininixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/mininixos/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

      # intel NUC
      nixosConfigurations.nucone = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/nucone/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

      # MiniPC NUC
      nixosConfigurations.kube-casa1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/kube-casa1/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

      # Hetzner Kubernetes
      nixosConfigurations.fsn-c1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { index = 1; } // commonSpecialArgs;
        modules = [
          ./hosts/fsn-c1/nixos/k3s.nix
          ./hosts/fsn-cN/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };
      nixosConfigurations.fsn-c2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { index = 2; } // commonSpecialArgs;
        modules = [
          ./hosts/fsn-c2/nixos/k3s.nix
          ./hosts/fsn-cN/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };
      nixosConfigurations.fsn-c3 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { index = 3; } // commonSpecialArgs;
        modules = [
          ./hosts/fsn-c3/nixos/k3s.nix
          ./hosts/fsn-cN/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

      # SOX1 Xtreme Gen2
      nixosConfigurations.sox1x = nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/sox1x/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

      darwinConfigurations = { };
      homeConfigurations = { };

    in
    {
      # Return all the configurations
      nixosConfigurations = nixosConfigurations;
      darwinConfigurations = darwinConfigurations;
      homeConfigurations = homeConfigurations;

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    };
}

# vim: set nu li sw=2 ts=2 expandtab
