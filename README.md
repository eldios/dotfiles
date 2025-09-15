# NixOS Dotfiles

<p align="center">
  <img src="assets/logo.png" alt="NixOS Dotfiles Logo" width="200"/>
</p>

NixOS + Home Manager configs for my machines.

## Setup

```bash
git clone https://github.com/eldios/dotfiles ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#$(hostname)
```

## Structure

```
dotfiles/
├── flake.nix          # Entrypoint
├── common/
│   ├── nixos/         # System config
│   └── home-manager/  # User config
├── hosts/             # Per-machine config
├── docs/              # Guides
└── secrets/           # SOPS
```

## Hosts

| Host | Type | Purpose |
|------|------|---------|
| `lele8845ace` | Laptop | Main dev |
| `lele9iyoga` | Laptop | Secondary |
| `wotah` | VM | Testing |
| `nucone` | Server | Home |
| `sox1x` | Server | Remote |
| `fsn-c*` | Cluster | K8s |

## Docs

- [Commands](docs/nixos-commands.md)
- [Theming](docs/theming.md)
- [New Host](docs/new-host.md)
