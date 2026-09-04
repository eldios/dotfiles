# AMD 8845HS AceMagic NUC: the desktop workstation.
{den, ...}: {
  den.aspects.lele8845ace = {
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
      den.aspects.gaming
      den.aspects.printing
      den.aspects.ai-tools
      den.aspects.gpu-amd
      den.aspects.tang-server
      den.aspects.clevis-unlock
    ];

    nixos = {inputs, ...}: {
      imports = [
        # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix
        inputs.nixos-hardware.nixosModules.common-cpu-amd
        inputs.nixos-hardware.nixosModules.common-hidpi
        inputs.nixos-hardware.nixosModules.common-pc-ssd

        inputs.disko.nixosModules.disko

        ./_lele8845ace/disko.nix
        ./_lele8845ace/boot.nix
        ./_lele8845ace/system.nix
        ./_lele8845ace/network.nix
      ];

      users.groups.i2c.members = ["eldios"];
    };

    # Host-specific Home Manager config for eldios: GPU env, monitors, packages.
    provides.eldios.homeManager = {
      imports = [
        ./_lele8845ace/display.nix
        ./_lele8845ace/pkgs.nix
      ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

