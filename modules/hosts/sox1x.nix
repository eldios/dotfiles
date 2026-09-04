# Lenovo ThinkPad X1 Extreme Gen2: Intel plus NVIDIA (PRIME offload) laptop,
# shared with a second local account.
{den, ...}: {
  den.aspects.sox1x = {
    includes = [
      den.aspects.base
      den.aspects.sops
      den.aspects.locale
      den.aspects.overlays
      den.aspects.dns
      den.aspects.nix-cache
      den.aspects.virtualisation
      den.aspects.neovim
      den.aspects.audio
      den.aspects.desktop-gui
      den.aspects.terminals
      den.aspects.hyprland
      den.aspects.gdm
      den.aspects.printing
      den.aspects.ai-tools
      den.aspects.gpu-nvidia
    ];

    nixos = {inputs, ...}: {
      imports = [
        # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

        ./_sox1x/hardware-configuration.nix
        ./_sox1x/boot.nix
        ./_sox1x/system.nix
        ./_sox1x/network.nix
      ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

