# domevh

OVH Milan VM - dev sandbox

## Pre-install

In secrets repo:

```bash
# Facter placeholder
mkdir -p facter
echo '{"version": 3, "system": "x86_64-linux"}' > facter/domevh.json

# Password (mkpasswd -m sha-512 to generate hash)
sops domevh.yaml
# Add: passwords.domevh.eldios: "$6$..."

git add facter/domevh.json domevh.yaml && git commit -m "domevh: secrets" && git push
```

Then in dotfiles:

```bash
nix flake update secrets
```

## Install

```bash
cd ~/dotfiles

nix run github:nix-community/nixos-anywhere -- \
  --flake .#domevh \
  --generate-hardware-config nixos-facter <secrets-repo>/facter/domevh.json \
  --disk main /dev/sda \
  --target-host root@<IP>
```

Use `--disk main /dev/vda` if virtio disk.

## Post-install

```bash
# Generate facter if placeholder wasn't replaced
ssh root@<IP> 'nix run nixpkgs#nixos-facter -- -o -' > <secrets-repo>/facter/domevh.json

# Get age key for SOPS
ssh root@<IP> cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
# Add to .sops.yaml, then: sops updatekeys domevh.yaml

# Commit secrets
git add facter/domevh.json .sops.yaml domevh.yaml && git commit && git push

# Rebuild with real secrets
cd ~/dotfiles
nix flake update secrets
nixos-rebuild switch --flake .#domevh --target-host root@<IP>
```

## Notes

- Hardware config (facter.json) in secrets repo (not encrypted, repo is private)
- Password: `passwords/domevh/eldios` in `domevh.yaml`
- Disk: btrfs (no LUKS)
