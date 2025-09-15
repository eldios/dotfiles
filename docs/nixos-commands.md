# NixOS Commands

## Quick Aliases

```bash
nixU    # nix flake update ~/dotfiles && nixu
nixu    # nixos-rebuild switch --flake ~/dotfiles
hmu     # home-manager switch -b backup --flake ~/dotfiles
hmU     # nixu && hmu
hmc     # home-manager expire-generations '-7 days' && nix-store --gc
nixs    # nix search nixpkgs
```

## Finding Packages

```bash
nix search nixpkgs neovim
nix eval nixpkgs#neovim.version
nix run nixpkgs#package    # try without installing
```

## Adding Packages

**System** → `common/nixos/system.nix`
```nix
environment.systemPackages = with pkgs; [ git wget ];
```

**User** → `common/home-manager/eldios/programs/packages_*.nix`
```nix
home.packages = with pkgs; [ lazygit ];
```

**Unstable** → `pkgs.unstable.package-name`

## Overlays

Create `common/nixos/overlays/package.nix`:
```nix
self: super: {
  package = super.package.overrideAttrs (old: rec {
    version = "x.y.z";
    src = self.fetchFromGitHub {
      owner = "owner"; repo = "repo"; rev = "v${version}";
      hash = "sha256-xxx";  # nix-prefetch-github owner repo --rev v${version}
    };
  });
}
```

Register in `common/nixos/system.nix`:
```nix
nixpkgs.overlays = [ (import ./overlays/package.nix) ];
```

## Hashes

```bash
# GitHub
nix-prefetch-github owner repo --rev tag

# NPM - use fakeHash trick
npmDeps = fetchNpmDeps { hash = lib.fakeHash; };
# Build, copy hash from error

# URL
nix-prefetch-url https://example.com/file.tar.gz
```

## Debug

```bash
nix build -L .#package           # verbose
nix build --keep-failed .#package # keep build dir
cd /tmp/nix-build-*
```

## Maintenance

```bash
sudo nix-collect-garbage -d
home-manager expire-generations '-7 days'
nix-store --gc
du -sh /nix/store
```

## Common Fixes

**Hash mismatch**: Copy "got:" hash from error

**Missing deps for Node**:
```nix
nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.pkg-config pkgs.python3 ];
buildInputs = old.buildInputs ++ [ pkgs.libsecret ];
```

**Network during build**: Can't. Pre-fetch everything or disable postinstall.