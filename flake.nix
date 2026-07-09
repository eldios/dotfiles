{
  description = "Lele's nix conf - for macOS and nixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

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

    mpc-hub = {
      url = "github:ravitemer/mcp-hub";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Omarchy launcher stack (Walker GTK frontend + Elephant provider daemon)
    walker.url = "github:abenz1267/walker/v2.16.2";
    elephant.url = "github:abenz1267/elephant";

    # Upstream omarchy repo — source of vendored scripts/themes/configs.
    # We pull bin/, default/, config/ as-is and override only Nix-specific bits.
    omarchy = {
      url = "github:basecamp/omarchy";
      flake = false;
    };

    # AI tool overlays (auto-updated by maintainers)
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    opencode-nix.url = "github:dan-online/opencode-nix";
    llm-agents-nix.url = "github:numtide/llm-agents.nix"; # for crush (charmbracelet)
    gws-cli.url = "github:googleworkspace/cli";
    herdr.url = "github:ogulcancelik/herdr"; # agent multiplexer for AI CLIs (uses its own nixpkgs-unstable)

    # Zen Browser — community flake (per https://wiki.nixos.org/wiki/Zen_Browser)
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    claude-code-overlay,
    codex-cli-nix,
    darwin,
    dgop,
    disko,
    gws-cli,
    herdr,
    llm-agents-nix,
    opencode-nix,
    home-manager,
    mpc-hub,
    nixos-hardware,
    nixpkgs,
    nixpkgs-darwin,
    nixpkgs-unstable,
    sops-nix,
    xremap,
    zen-browser,
    ...
  } @ inputs: let
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
        claude-code-overlay
        codex-cli-nix
        dgop
        disko
        gws-cli
        herdr
        home-manager
        llm-agents-nix
        opencode-nix
        inputs
        mpc-hub
        nixos-hardware
        nixpkgs
        nixpkgs-darwin
        nixpkgs-unstable
        sops-nix
        xremap
        zen-browser
        ;
    };

    # NixOS hosts. Each host ships its own configuration.nix and shares disko and
    # sops-nix, so they are all built from one helper.
    mkHost = host:
      nixpkgs.lib.nixosSystem {
        specialArgs = commonSpecialArgs;
        modules = [
          ./hosts/${host}/nixos/configuration.nix
          disko.nixosModules.disko
          sops-nix.nixosModules.sops
        ];
      };

    nixosConfigurations = nixpkgs.lib.genAttrs [
      "lele8845ace" # AMD 8845 AceMagic NUC
      "lele9iyoga" # Yoga9i (Intel) laptop
      "mininixos" # Minis NUC (storage / services)
      "sox1x" # SOX1 Xtreme Gen2
    ] mkHost;

    # darwinConfigurations: Defines macOS system configurations using nix-darwin.
    # Similar structure to nixosConfigurations, but for Apple systems.
    # Currently empty, but structured for future macOS hosts.
    darwinConfigurations = {};

    # homeConfigurations: Defines user-specific environments using Home Manager.
    # These can be applied on top of NixOS or darwin configurations, or even standalone.
    # Allows managing dotfiles, user packages, and services.
    # Currently empty, but structured for future user profiles not tied to a specific host system configuration.
    homeConfigurations = {};
  in {
    # Return all the configurations
    nixosConfigurations = nixosConfigurations; # All defined NixOS systems
    darwinConfigurations = darwinConfigurations; # All defined macOS systems
    homeConfigurations = homeConfigurations; # All defined Home Manager user profiles

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
# vim: set nu li sw=2 ts=2 expandtab

