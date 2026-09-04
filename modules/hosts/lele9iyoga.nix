# Lenovo Yoga 9i, Intel laptop.
{den, ...}: {
  den.aspects.lele9iyoga = {
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
      den.aspects.gaming
      den.aspects.printing
      den.aspects.ai-tools
      den.aspects.cli
      den.aspects.gpu-intel
      den.aspects.laptop
    ];

    nixos = {inputs, ...}: {
      imports = [
        # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-hidpi
        inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd

        inputs.disko.nixosModules.disko

        ./_lele9iyoga/disko.nix
        ./_lele9iyoga/boot.nix
        ./_lele9iyoga/system.nix
        ./_lele9iyoga/network.nix
      ];
    };

    # Host-specific Home Manager config for eldios: GPU env, HiDPI, key remap.
    provides.eldios.homeManager = {
      imports = [
        ./_lele9iyoga/home.nix
        ./_lele9iyoga/display.nix
        ./_lele9iyoga/xremap.nix
      ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

