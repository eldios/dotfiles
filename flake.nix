{
  description = "Lele's nix conf - for macOS and nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";

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

    zen-browser.url = "github:MarceColl/zen-browser-flake";

    secrets = {
      url = "git+ssh://git@github.com/eldios/secrets.git?ref=main&shallow=1";
      flake = false;
    };

    portmaster.url = "github:railwhale/nixpkgs/portmaster";

    peerix = {
      url = "github:tomasharkema/peerix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , darwin
    , disko
    , home-manager
    , nixos-hardware
    , nixpkgs-darwin
    , nixpkgs-unstable
    , peerix
    , portmaster
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
          disko
          home-manager
          inputs
          nixos-hardware
          nixpkgs
          nixpkgs-darwin
          nixpkgs-unstable
          peerix
          portmaster
          sops-nix
          xremap
          ;
      };

      # Lele's AMD 8845 AceMagic NUC
      nixosConfigurations.lele8845ace = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/lele8845ace/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          peerix.nixosModules.peerix
        ];
      };

      # Lele's Yoga9i
      nixosConfigurations.lele9iyoga = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/lele9iyoga/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          peerix.nixosModules.peerix
        ];
      };

      # Minis NUC
      nixosConfigurations.wotah = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/wotah/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
          peerix.nixosModules.peerix
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
          peerix.nixosModules.peerix
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
          peerix.nixosModules.peerix
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
          peerix.nixosModules.peerix
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
