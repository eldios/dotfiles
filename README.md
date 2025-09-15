<p align="center">
  <img src="assets/logo.png" alt="NixOS Dotfiles Logo" width="980"/>
</p>

<h1 align="center">NixOS Dotfiles</h1>

<p align="center">
  <a href="https://nixos.org/"><img src="https://img.shields.io/badge/NixOS-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS"></a>
  <a href="https://github.com/nix-community/home-manager"><img src="https://img.shields.io/badge/Home_Manager-5277C3?style=for-the-badge&logo=nixos&logoColor=white" alt="Home Manager"></a>
  <a href="https://github.com/Mic92/sops-nix"><img src="https://img.shields.io/badge/SOPS-FF6C37?style=for-the-badge&logo=terraform&logoColor=white" alt="SOPS"></a>
  <a href="https://github.com/neovim/neovim"><img src="https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white" alt="Neovim"></a>
  <a href="https://github.com/tmux/tmux"><img src="https://img.shields.io/badge/Tmux-1BB91F?style=for-the-badge&logo=tmux&logoColor=white" alt="Tmux"></a>
  <a href="https://github.com/alacritty/alacritty"><img src="https://img.shields.io/badge/Alacritty-F46D01?style=for-the-badge&logo=alacritty&logoColor=white" alt="Alacritty"></a>
  <a href="https://hyprland.org/"><img src="https://img.shields.io/badge/Hyprland-00ACC1?style=for-the-badge&logo=wayland&logoColor=white" alt="Hyprland"></a>
  <a href="https://github.com/zsh-users/zsh"><img src="https://img.shields.io/badge/Zsh-1A2C34?style=for-the-badge&logo=gnu-bash&logoColor=white" alt="Zsh"></a>
</p>

<p align="center">
  <b>NixOS + Home Manager configs for my machines</b>
</p>

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
