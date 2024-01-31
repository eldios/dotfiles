{
  description = "Lele's nix conf - for macOS and nixOS";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-23.11";
    darwin.url           = "github:lnl7/nix-darwin";

    home-manager.url     = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url           = "github:nix-community/nixvim";
    nix-colors.url       = "github:misterio77/nix-colors";
    nixos-hardware.url   = "github:nixos/nixos-hardware";
  };

  outputs = {
    darwin,
    home-manager,
    nixos-hardware,
    nixvim,
    flake-parts,
    nix-colors,
    ...
  } @ inputs: let
    inherit (
      nixpkgs
    );

    nixpkgs = inputs.nixpkgs ;

    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    # Define common specialArgs for nixosConfigurations and homeConfigurations
    commonSpecialArgs = { inherit
      inputs
      home-manager
      nixos-hardware
      nixvim
      flake-parts
      nix-colors
      ;
    };

    # nixOS configuration entrypoint
    #   nixos-rebuild --flake '/flake/directory/.#your-hostname'
    # Home-manager configuration standalone entrypoint
    #   home-manager --flake '/flake/directory/.#your-username@your-hostname'

    # Lele's X1 Yoga
    nixosConfigurations.lelex1yoga = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/lelex1yoga/nixos/configuration.nix ];
    };
    homeConfigurations."eldios@lelex1yoga" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/lelex1yoga/home-manager/home.nix ];
    };

    # Minis NUC
    nixosConfigurations.mininixos = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/mininixos/nixos/configuration.nix ];
    };
    homeConfigurations."eldios@mininixos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/mininixos/home-manager/home.nix ];
    };

    # intel NUC
    nixosConfigurations.nucone = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/nucone/nixos/configuration.nix ];
    };
    homeConfigurations."eldios@nucone" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/nucone/home-manager/home.nix ];
    };

    # LeleM1 (macOS)
    darwinConfigurations.LeleM1 = darwin.lib.darwinSystem {
      specialArgs = commonSpecialArgs;
      system = "aarch64-darwin";
      modules = [ /Users/eldios/go/src/github.com/eldios/.dotfiles/hosts/LeleM1/darwin/configuration.nix ];
    };
    homeConfigurations."eldios@LeleM1" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ /Users/eldios/go/src/github.com/eldios/.dotfiles/hosts/LeleM1/home-manager/home.nix ];
    };

    # SOX1 Xtreme Gen2
    nixosConfigurations.sox1x = nixpkgs.lib.nixosSystem {
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/sox1x/nixos/configuration.nix ];
    };
    homeConfigurations."eldios@sox1x" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/sox1x/home-manager/home.nix ];
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
