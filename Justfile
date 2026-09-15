# Routine commands for this repo. Every tool they need is in the dev shell
# (nix develop) and in the fleet's base profile (modules/aspects/_base).

default:
    @just --list

# Report which custom-packaged versions are behind upstream (writes nothing)
outdated:
    ./scripts/update-versions.sh --check all

# Update one custom version: overlay pin + hashes, atomically, hash by hash
update pkg:
    nice -n 19 ./scripts/update-versions.sh {{pkg}}

# Update every custom version in sequence (stops at the first failure;
# hashes already written stay written)
update-all:
    nice -n 19 ./scripts/update-versions.sh all

# Evaluate every host toplevel: catches config errors before any switch
eval-all:
    for h in $(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[]'); do \
      nice -n 19 nix eval ".#nixosConfigurations.$h.config.system.build.toplevel.drvPath"; \
    done

# Format nix files with the flake formatter (alejandra reads stdin when
# given no path, so the tree is passed explicitly)
fmt:
    nix fmt -- .

# Check formatting without writing anything
fmt-check:
    nix fmt -- --check .

# Lint the repo scripts
lint:
    shellcheck scripts/*.sh

# Everything a change has to pass before it is landed
ci: fmt-check lint eval-all
