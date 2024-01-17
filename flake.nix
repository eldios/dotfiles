{
  description = "Lele's nix conf - for macOS and nixOS";

  inputs = {
    nixpkgs.url        = "github:nixos/nixpkgs/nixos-unstable";
    darwin.url         = "github:lnl7/nix-darwin";
    home-manager.url   = "github:nix-community/home-manager";
    nixvim.url         = "github:nix-community/nixvim";
    nix-colors.url     = "github:misterio77/nix-colors";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    nixvim,
    flake-parts,
    nix-colors,
    ...
  } @ inputs: let
    inherit (self) outputs;

    # Define common specialArgs for nixosConfigurations and homeConfigurations
    commonSpecialArgs = { inherit self inputs nixvim flake-parts nix-colors ; };

    # nixOS configuration entrypoint
    #   'nixos-rebuild --flake .#your-hostname'
    # Home-manager configuration standalone entrypoint
    #   'home-manager --flake .#your-username@your-hostname'

    # Lele's X1 Yoga
    nixosConfigurations.lelex1yoga = nixpkgs.lib.nixosSystem {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/lelex1yoga/configuration.nix ];
    };
    homeConfigurations."eldios@lelex1yoga" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/lelex1yoga/home.nix ];
    };

    # Minis NUC
    nixosConfigurations.mininixos = nixpkgs.lib.nixosSystem {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/mininixos/configuration.nix ];
    };
    homeConfigurations."eldios@mininixos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/mininixos/home.nix ];
    };

    # intel NUC
    nixosConfigurations.nucone = nixpkgs.lib.nixosSystem {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/nucone/configuration.nix ];
    };
    homeConfigurations."eldios@nucone" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/nucone/home.nix ];
    };

    # LeleM1 (macOS)
    darwinConfigurations.LeleM1 = darwin.lib.darwinSystem {
      specialArgs = commonSpecialArgs;
      modules = [ ./hosts/LeleM1/configuration.nix ];
    };
    homeConfigurations."eldios@LeleM1" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      extraSpecialArgs = commonSpecialArgs;
      modules = [ ./hosts/LeleM1/home.nix ];
    };

  in {
    # Return all the configurations
    nixosConfigurations  = nixosConfigurations;
    darwinConfigurations = darwinConfigurations;
    homeConfigurations   = homeConfigurations;
  };
}

# vim: set nu li sw=2 ts=2 expandtab
