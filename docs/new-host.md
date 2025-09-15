# New Host Setup

## Steps

### 1. Copy template
```bash
cp -r hosts/wotah hosts/new-hostname
```

### 2. Hardware config
```bash
nixos-generate-config --show-hardware-config > hosts/new-hostname/nixos/hardware.nix
```

### 3. Add to flake.nix
```nix
new-hostname = nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [ ./hosts/new-hostname/nixos/configuration.nix ];
};
```

### 4. Deploy
```bash
sudo nixos-rebuild switch --flake .#new-hostname
```

## Files to Edit

- `hosts/new-hostname/nixos/configuration.nix` - Main config
- `hosts/new-hostname/nixos/boot.nix` - Bootloader
- `hosts/new-hostname/nixos/disko.nix` - Disk layout
- `hosts/new-hostname/nixos/system.nix` - Hostname

## Test First

```bash
# Build only
sudo nixos-rebuild build --flake .#new-hostname

# VM test
nixos-rebuild build-vm --flake .#new-hostname
./result/bin/run-new-hostname-vm
```
