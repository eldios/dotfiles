# NixOS commands

## Quick aliases

Defined in `modules/aspects/dev/_cli/zsh.nix`. `nh` reads the flake path from
`programs.nh.flake`, so none of them need to be run from the repo.

```bash
nixu    # nh os switch (build as user through nix-daemon, sudo only to activate)
nixU    # nh os switch --update (updates every flake input first)
nixuo   # nixu with only the public caches (outside the home network)
nixe    # $EDITOR ~/dotfiles
hmu     # nh home switch -b backup
hmU     # nixu && hmu
hmc     # home-manager expire-generations '-7 days' && nix-store --gc
nixs    # nix search nixpkgs
```

The `*.old` variants of `nixu`, `nixU` and `hm-update` run the plain
`nixos-rebuild` and `home-manager` commands.

## Repo recipes

```bash
just eval-all       # evaluate every host toplevel, catches errors before a switch
just outdated       # which custom-packaged versions are behind upstream
just update <pkg>   # bump one pinned overlay: version, hashes, eval check
just update-all     # the same for every pin, in sequence
just fmt            # nix fmt
just lint           # shellcheck scripts/*.sh
```

`outdated` and `update` drive `scripts/update-versions.sh`; the packages it
knows are listed in its usage line. `nix develop` provides the tools the
scripts need.

## Finding packages

```bash
nix search nixpkgs neovim
nix eval nixpkgs#neovim.version
nix run nixpkgs#package    # try without installing
```

## Adding packages

**System**: `modules/aspects/_base/system.nix`
```nix
environment.systemPackages = with pkgs; [ git wget ];
```

**User**: the package set under the aspect that owns it, for example
`modules/aspects/dev/_cli/packages_common_cli.nix` for CLI tools or
`modules/aspects/desktop/_desktop-gui/packages_common_gui.nix` for graphical
ones:
```nix
home.packages = with pkgs; [ lazygit ];
```

**Unstable**: `pkgs.unstable.package-name`. The namespace comes from the
`unstable-packages` overlay, which imports the `nixpkgs-unstable` input with
the same config as the stable set.

## Aspects

A feature is a den module under `modules/aspects/` declaring
`den.aspects.<name>` with a `nixos` and/or `homeManager` class. Plain modules
belong next to it under a `_` path, which the loader skips:

```nix
# modules/aspects/thing.nix
{
  den.aspects.thing = {
    nixos.imports = [./_thing/nixos.nix];
    homeManager.imports = [./_thing/hm.nix];
  };
}
```

Then add `den.aspects.thing` to the include list of the hosts that want it in
`modules/hosts/<host>.nix`. Users on that host receive the `homeManager` half
through den's `host-aspects` battery. An aspect can include others
(`includes = [den.aspects.desktop-gui];`) and expose sub-aspects through
`provides.<sub>`, addressed as `den.aspects.<name>.<sub>`.

## Overlays

Overlays live in `modules/aspects/_overlays/` and are registered once, for
every host, in `modules/aspects/overlays.nix`. An overlay is lazy, so an entry
costs nothing on a host that never references its package.

```nix
# modules/aspects/_overlays/package.nix
final: prev: {
  package = prev.package.overrideAttrs (old: rec {
    version = "x.y.z";
    src = final.fetchFromGitHub {
      owner = "owner"; repo = "repo"; rev = "v${version}";
      hash = "sha256-xxx";  # nix-prefetch-github owner repo --rev v${version}
    };
  });
}
```

```nix
# modules/aspects/overlays.nix
den.aspects.overlays.nixos.nixpkgs.overlays = [
  (import ./_overlays/package.nix)
];
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
nh clean all --keep 5
home-manager expire-generations '-7 days'
nix-store --gc
du -sh /nix/store
```

## Common fixes

**Hash mismatch**: copy the "got:" hash from the error.

**Missing deps for Node**:
```nix
nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.pkg-config pkgs.python3 ];
buildInputs = old.buildInputs ++ [ pkgs.libsecret ];
```

**Network during build**: not possible. Pre-fetch everything or disable postinstall.
