{
  description = "Lele's nix conf - for macOS and nixOS";

  inputs = {
    # usual inputs
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-23.11";
    home-manager.url     = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url   = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    darwin.url           = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # base imports
    utils.url = "github:numtide/flake-utils";

    # additional utils
    nixos-hardware.url   = "github:nixos/nixos-hardware";
    xremap.url = "github:xremap/nix-flake";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-darwin,
    home-manager,
    darwin,
    nixos-hardware,
    disko,
    sops-nix,
    xremap,
    ...
  } @ inputs: let

    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    # Define common specialArgs for nixosConfigurations and homeConfigurations
    commonSpecialArgs = { inherit
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

    # Lele's X1 Yoga
    nixosConfigurations.lelex1yoga = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [
        ./hosts/lelex1yoga/nixos/configuration.nix
      ];
    };

    # Lele's Yoga9i
    nixosConfigurations.lele9iyoga = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [
        ./hosts/lele9iyoga/nixos/configuration.nix
      ];
    };

    # Minis NUC
    nixosConfigurations.mininixos = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [
        ./hosts/mininixos/nixos/configuration.nix
      ];
    };

    # intel NUC
    nixosConfigurations.nucone = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [
        ./hosts/nucone/nixos/configuration.nix
      ];
    };

    # MiniPC NUC
    nixosConfigurations.kube-casa1 = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [
        ./hosts/kube-casa1/nixos/configuration.nix
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
      ];
    };
    nixosConfigurations.fsn-c2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { index = 2; } // commonSpecialArgs;
      modules = [
        ./hosts/fsn-c2/nixos/k3s.nix
        ./hosts/fsn-cN/nixos/configuration.nix
        disko.nixosModules.disko
      ];
    };
    nixosConfigurations.fsn-c3 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { index = 3; } // commonSpecialArgs;
      modules = [
        ./hosts/fsn-c3/nixos/k3s.nix
        ./hosts/fsn-cN/nixos/configuration.nix
        disko.nixosModules.disko
      ];
    };

    nixosConfigurations.fsn-w1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = commonSpecialArgs;
      modules = [
        ./hosts/fsn-w1/nixos/configuration.nix
        disko.nixosModules.disko
      ];
    };

    # LeleM1 (macOS)
    darwinConfigurations.LeleM1 = darwin.lib.darwinSystem {
      specialArgs = commonSpecialArgs ;
      system = "aarch64-darwin";
      modules = [
        ./hosts/LeleM1/darwin/configuration.nix
      ];
    };

    # SOX1 Xtreme Gen2
    nixosConfigurations.sox1x = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [
        ./hosts/sox1x/nixos/configuration.nix
      ];
    };
    homeConfigurations."eldios@sox1x" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [
        ./hosts/sox1x/home-manager/home.nix
      ];
    };

  in {
    # Return all the configurations
    nixosConfigurations  = nixosConfigurations;
    darwinConfigurations = darwinConfigurations;
    homeConfigurations   = homeConfigurations;

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}

# vim: set nu li sw=2 ts=2 expandtab
