# Routine commands for this repo. `just` comes from common/nixos/system.nix;
# the exotic tools the scripts need are wrapped in nix-shell or provided by
# the dev shell (nix develop).

default:
    @just --list

# Report which custom-packaged versions are behind upstream (writes nothing)
outdated:
    ./scripts/update-versions.sh --check all

# Update one custom version: overlay pin + hashes, atomically, hash by hash
update pkg:
    ./scripts/update-versions.sh {{pkg}}

# Update every custom version in sequence (stops at the first failure;
# hashes already written stay written)
update-all:
    ./scripts/update-versions.sh all

# Evaluate every host toplevel: catches config errors before any switch
eval-all:
    for h in lele8845ace lele9iyoga sox1x mininixos; do \
      nice -n 19 nix eval ".#nixosConfigurations.$h.config.system.build.toplevel.drvPath"; \
    done

# Format nix files with the flake formatter
fmt:
    nix fmt

# Lint the repo scripts
lint:
    nix-shell -p shellcheck --run 'shellcheck scripts/*.sh'
