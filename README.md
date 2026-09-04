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
  <b>NixOS + Home Manager configs for my machines, composed with <a href="https://github.com/denful/den">den</a></b>
</p>

## Setup

```bash
git clone https://github.com/eldios/dotfiles ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#$(hostname)
```

Once the config is active, the `nixu` alias does the same through
`nh os switch` (built as the regular user, activated with sudo).

## Structure

```
dotfiles/
├── flake.nix                # Inputs; every file under modules/ is a den module
├── modules/
│   ├── den.nix              # den wiring shared by every host and user
│   ├── hosts.nix            # The hosts that exist, with their users
│   ├── flake-outputs.nix    # formatter and dev shell
│   ├── aspects/             # One aspect per feature (base, sops, hyprland, ...)
│   ├── hosts/<host>.nix     # Which aspects each host includes
│   ├── users/<user>.nix     # Users are aspects too
│   └── _assets/             # Files read by modules (ssh keys)
├── docs/                    # Guides
├── scripts/                 # Version bumps for the pinned overlays
└── Justfile                 # Routine commands
```

Any path starting with `_` is skipped by the module loader and holds plain
NixOS or Home Manager modules, imported by the aspect or host next to it.

## The model

A host is a list of aspects. An aspect bundles the NixOS and Home Manager
halves of one feature: `den.aspects.neovim` carries the system editor in its
`nixos` class and the LazyVim setup in its `homeManager` class, and a host
that includes it gets both. Users are aspects as well: `modules/users/eldios.nix`
includes den's `define-user`, `primary-user` and `user-shell` batteries for the
account itself, and `host-aspects`, which hands the user the Home Manager half
of every aspect the host includes. Configuration that belongs to one user on
one host goes through `provides.<user>.homeManager` in the host's aspect.

Secrets come from a private repo through the `secrets` flake input, consumed
by sops-nix; there is no `secrets/` directory here.

## Hosts

| Host | Role |
|------|------|
| `lele8845ace` | Desktop workstation |
| `lele9iyoga` | Laptop |
| `sox1x` | Laptop, shared with a second account |
| `mininixos` | Headless server: storage and services |

## Docs

- [Commands](docs/nixos-commands.md)
- [Theming](docs/theming.md)
- [New host](docs/new-host.md)
