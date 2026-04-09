{
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  nixos-hardware,
  home-manager,
  claude-code-overlay,
  codex-cli-nix,
  gemini-cli-nix,
  gws-cli,
  llm-agents-nix,
  opencode-nix,
  ...
}:
{
  # Apply overlays here to avoid warning with home-manager.useGlobalPkgs
  nixpkgs.overlays = [
    (import ../../../common/nixos/overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
    claude-code-overlay.overlays.default
    codex-cli-nix.overlays.default
    gemini-cli-nix.overlays.default
    opencode-nix.overlays.default
    (import ../../../common/nixos/overlays/crush.nix { inherit llm-agents-nix; })
    (import ../../../common/nixos/overlays/gws-cli.nix { inherit gws-cli; })
    (import ../../../common/nixos/overlays/gitbutler.nix)
  ];

  imports = [
    # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
    nixos-hardware.nixosModules.common-cpu-amd
    # nixos-hardware.nixosModules.common-cpu-amd-pstate  # removed: sets amd_pstate=active which worsens TSC desync hangs; passive mode set in boot.nix
    nixos-hardware.nixosModules.common-gpu-amd
    nixos-hardware.nixosModules.common-pc-laptop-ssd

    ../../../common/nixos/sops.nix

    ../../../common/nixos/locale.nix
    ../../../common/nixos/locale_gui.nix

    ../../../common/nixos/users.nix
    ../../../common/nixos/system.nix
    ../../../common/nixos/audio.nix
    ../../../common/nixos/nix-cache.nix

    ../../../common/nixos/programs/neovim.nix
    ../../../common/nixos/programs/hyprland.nix
    ../../../common/nixos/programs/niri.nix

    ../../../common/nixos/virtualisation.nix
    ../../../common/nixos/desktop-gui.nix

    ./disko.nix

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
