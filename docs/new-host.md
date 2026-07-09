# New Host Setup

## Steps

### 1. Copy an existing host as a template
```bash
cp -r hosts/lele9iyoga hosts/new-hostname
```

### 2. Disk / hardware config

Laptops (`lele8845ace`, `lele9iyoga`) declare disks with disko (`disko.nix`) and
pull hardware profiles from `nixos-hardware` modules imported in
`configuration.nix`. Servers (`mininixos`, `sox1x`) keep a generated
`hardware-configuration.nix`:
```bash
nixos-generate-config --show-hardware-config > hosts/new-hostname/nixos/hardware-configuration.nix
```
Then adjust `disko.nix` (or the hardware import) for the new machine's disks.

### 3. Add to flake.nix

Hosts are built by the `mkHost` helper; just add the hostname to the
`nixosConfigurations` list:
```nix
nixosConfigurations = nixpkgs.lib.genAttrs [
  "lele8845ace"
  "lele9iyoga"
  "mininixos"
  "sox1x"
  "new-hostname" # add here
] mkHost;
```

### 4. Deploy
```bash
sudo nixos-rebuild switch --flake .#new-hostname
```

## Files to Edit

- `hosts/new-hostname/nixos/configuration.nix` - Main config
- `hosts/new-hostname/nixos/boot.nix` - Bootloader
- `hosts/new-hostname/nixos/disko.nix` - Disk layout
- `hosts/new-hostname/nixos/network.nix` - Hostname (`networking.hostName`)
- `hosts/new-hostname/nixos/system.nix` - System settings

## Test First

```bash
# Build only
sudo nixos-rebuild build --flake .#new-hostname

# VM test
nixos-rebuild build-vm --flake .#new-hostname
./result/bin/run-new-hostname-vm
```
