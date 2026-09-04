# Minisforum NUC: headless storage and services box.
{den, ...}: {
  den.aspects.mininixos = {
    includes = [
      den.aspects.base
      den.aspects.sops
      den.aspects.locale
      den.aspects.overlays
      den.aspects.dns
      den.aspects.nix-cache
      den.aspects.virtualisation
      den.aspects.neovim
      den.aspects.gpu-amd
      den.aspects.tang-server
      den.aspects.clevis-unlock
      den.aspects.backup-server
      # The MCP server fleet runs here too, without the desktop AI clients.
      den.aspects.ai-tools.mcp-servers
    ];

    nixos = {inputs, ...}: {
      imports = [
        # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        inputs.nixos-hardware.nixosModules.common-cpu-amd
        inputs.nixos-hardware.nixosModules.common-pc-ssd

        inputs.disko.nixosModules.disko

        ./_mininixos/disko.nix
        ./_mininixos/boot.nix
        ./_mininixos/system.nix
        ./_mininixos/network.nix
        ./_mininixos/gpu.nix
        ./_mininixos/data-storage.nix
        ./_mininixos/srv-storage.nix
        ./_mininixos/archive-storage.nix
        ./_mininixos/libvirt-vms.nix
        ./_mininixos/portainer.nix
      ];
    };

    # Host-specific Home Manager config for eldios: ROCm packages, signing key.
    provides.eldios.homeManager = {
      imports = [
        ./_mininixos/pkgs.nix
        ./_mininixos/git.nix
      ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

