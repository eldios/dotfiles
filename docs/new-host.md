# New host setup

A host is three things: an entry in `modules/hosts.nix`, an aspect in
`modules/hosts/<host>.nix` listing what it includes, and the machine-specific
modules under `modules/hosts/_<host>/`.

## 1. Declare the host

Add it to `den.hosts.x86_64-linux` in `modules/hosts.nix` with its users:

```nix
new-hostname = {
  users.eldios = {};
};
```

Users default to a Home Manager environment (`den.schema.user.classes` in
`modules/den.nix`); a plain account with no Home Manager sets
`users.<name>.classes = ["user"]`. Host metadata lives here too: `luksRoot`
names the root LUKS mapper and is required only when the host includes the
`clevis-unlock` aspect, which reads it.

## 2. Write the host aspect

Create `modules/hosts/<host>.nix` with the include list. Every host includes
`base`, `sops`, `locale`, `overlays`, `dns`, `nix-cache`, `virtualisation` and
`neovim`. A desktop adds `audio`, `desktop-gui`, `terminals`, `hyprland`, `gdm`,
`printing`, `ai-tools` and one `gpu-*` aspect (`gpu-amd`, `gpu-intel`,
`gpu-nvidia`); a laptop adds `laptop`. Users are not listed: den applies the
aspects of the users declared in `hosts.nix`.

```nix
{den, ...}: {
  den.aspects.new-hostname = {
    includes = [
      den.aspects.base
      den.aspects.sops
      den.aspects.locale
      den.aspects.overlays
      den.aspects.dns
      den.aspects.nix-cache
      den.aspects.virtualisation
      den.aspects.neovim
    ];

    nixos = {inputs, ...}: {
      imports = [
        inputs.nixos-hardware.nixosModules.common-cpu-intel
        inputs.nixos-hardware.nixosModules.common-pc-ssd
        inputs.disko.nixosModules.disko

        ./_new-hostname/disko.nix
        ./_new-hostname/boot.nix
        ./_new-hostname/system.nix
        ./_new-hostname/network.nix
      ];
    };

    # Home Manager config that belongs to this user on this host only.
    provides.eldios.homeManager = {
      imports = [./_new-hostname/display.nix];
    };
  };
}
```

Disko and the `nixos-hardware` profiles are imported from `inputs.` inside the
host's `nixos` fragment; pick profiles from the
[nixos-hardware flake](https://github.com/NixOS/nixos-hardware/blob/master/flake.nix).

## 3. Machine-specific modules

Put them under `modules/hosts/_<host>/`, one concern per file:

- `disko.nix` - disk layout (or a generated `hardware-configuration.nix` from
  `nixos-generate-config --show-hardware-config` for a machine without disko)
- `boot.nix` - bootloader and kernel
- `system.nix` - system settings
- `network.nix` - interfaces, bridges, firewall

The hostname is not set here: den's `hostname` battery (in `modules/den.nix`)
takes it from the host name in `hosts.nix`. Home Manager fragments such as
monitor layouts (`desktop.hyprland.monitors`) or extra packages go in the same
directory and are imported through `provides.<user>.homeManager`.

## 4. Test first

```bash
# Every host must still evaluate
just eval-all

# Build only
sudo nixos-rebuild build --flake .#new-hostname

# VM test
nixos-rebuild build-vm --flake .#new-hostname
./result/bin/run-new-hostname-vm
```

## 5. Deploy

```bash
sudo nixos-rebuild switch --flake .#new-hostname
```
