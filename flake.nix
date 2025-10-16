{
  description = "Lele's nix conf - for macOS and nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";

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

    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
    };

    winboat = {
      url = "github:TibixDev/winboat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/eldios/secrets.git?ref=main&shallow=1";
      flake = false;
    };

    portmaster = {
      url = "github:railwhale/nixpkgs/portmaster";
    };

    stylix = {
      url = "github:danth/stylix/release-25.05";
    };

    mpc-hub = {
      url = "github:ravitemer/mcp-hub";
    };
  };

  outputs =
    {
      nixpkgs,
      darwin,
      disko,
      home-manager,
      mpc-hub,
      nixos-hardware,
      nixpkgs-darwin,
      nixpkgs-unstable,
      portmaster,
      sops-nix,
      stylix,
      winboat,
      xremap,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      # commonSpecialArgs: A set of common arguments passed to all system configurations.
      # This helps avoid repetition and ensures consistency across different hosts.
      # It includes inputs from other flakes (like home-manager, sops-nix) and nixpkgs instances.
      commonSpecialArgs = {
        inherit
          disko
          home-manager
          inputs
          mpc-hub
          nixos-hardware
          nixpkgs
          nixpkgs-darwin
          nixpkgs-unstable
          portmaster
          sops-nix
          stylix
          winboat
          xremap
          ;
      };

      # nixosConfigurations: Defines the NixOS system configurations for various hosts.
      # Each entry (e.g., lele8845ace) represents a distinct machine and imports
      # its specific hardware and software configuration modules.
      # Lele's AMD 8845 AceMagic NUC
      nixosConfigurations.lele8845ace = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/lele8845ace/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
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

      # SOX1 Xtreme Gen2
      nixosConfigurations.sox1x = nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/sox1x/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

      # darwinConfigurations: Defines macOS system configurations using nix-darwin.
      # Similar structure to nixosConfigurations, but for Apple systems.
      # Currently empty, but structured for future macOS hosts.
      darwinConfigurations = { };

      # homeConfigurations: Defines user-specific environments using Home Manager.
      # These can be applied on top of NixOS or darwin configurations, or even standalone.
      # Allows managing dotfiles, user packages, and services.
      # Currently empty, but structured for future user profiles not tied to a specific host system configuration.
      homeConfigurations = { };

    in
    {
      # Return all the configurations
      nixosConfigurations = nixosConfigurations; # All defined NixOS systems
      darwinConfigurations = darwinConfigurations; # All defined macOS systems
      homeConfigurations = homeConfigurations; # All defined Home Manager user profiles

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    };
}

# vim: set nu li sw=2 ts=2 expandtab
