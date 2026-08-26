#!/usr/bin/env bash
# Update the custom-packaged versions in this repo: overlay pins (version +
# hashes) and tag-pinned flake inputs. Each package updates atomically, hash
# by hash: everything discovered is written to disk immediately, so a failing
# step never invalidates the hashes already computed.
#
# Usage:
#   scripts/update-versions.sh [--check] <package>|all
# Packages: buzz antigravity pi qbz gitbutler vm-curator
# --check only reports current vs latest, writes nothing.
set -euo pipefail
cd "$(dirname "$0")/.."

CHECK=0
[[ ${1:-} == "--check" ]] && { CHECK=1; shift; }
TARGET="${1:-all}"

HOST="lele8845ace" # any host: the package set is the same on all of them
FAKE="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

log() { printf '\033[1m[%s]\033[0m %s\n' "${PKG:-?}" "$*"; }

# Literal in-file replacement; refuses to continue when the pattern is absent.
replace() { # file old new
  python3 - "$1" "$2" "$3" <<'EOF'
import sys
path, old, new = sys.argv[1:4]
s = open(path).read()
if old not in s:
    sys.exit(f"pattern not found in {path}: {old[:70]}")
open(path, "w").write(s.replace(old, new, 1))
EOF
}

gh_latest_release() { # repo -> tag_name
  curl -sf "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}

gh_latest_tag() { # repo [prefix-filter] -> first matching tag
  curl -sf "https://api.github.com/repos/$1/tags?per_page=10" \
    | jq -r --arg p "${2:-}" '[.[].name | select(startswith($p))][0]'
}

prefetch_url() { nix store prefetch-file --json "$1" | jq -r .hash; }
prefetch_github() { nix flake prefetch --json "github:$1" | jq -r .hash; }

file_version() { grep -oP 'version = "\K[^"]+' "$1" | head -1; }

# Realize a fixed-output derivation carrying $FAKE and return the real hash
# nix reports in the mismatch error.
fod_hash() { # attr
  local out
  out=$(nix build --no-link ".#nixosConfigurations.$HOST.pkgs.$1" 2>&1 || true)
  grep -oP 'got:\s+\Ksha256-\S+' <<<"$out" | head -1
}

eval_ok() { # attr
  nix eval --raw ".#nixosConfigurations.$HOST.pkgs.$1.drvPath" >/dev/null
  log "eval ok"
}

report() { # current latest -> returns 1 when already up to date
  if [[ "$1" == "$2" ]]; then
    log "gia' aggiornato ($1)"
    return 1
  fi
  log "$1 -> $2"
  [[ $CHECK == 1 ]] && return 1
  return 0
}

update_buzz() {
  PKG=buzz f=common/nixos/overlays/buzz-desktop.nix
  local cur latest ver url old new
  cur=$(file_version "$f")
  latest=$(curl -sf 'https://api.github.com/repos/block/buzz/releases?per_page=15' \
    | jq -r '[.[].tag_name | select(startswith("desktop-v"))][0]')
  ver="${latest#desktop-v}"
  report "$cur" "$ver" || return 0
  url="https://github.com/block/buzz/releases/download/desktop-v${ver}/Buzz_${ver}_amd64.AppImage"
  new=$(prefetch_url "$url")
  old=$(grep -oP 'hash = "\Ksha256-[^"]+' "$f" | head -1)
  replace "$f" "version = \"$cur\";" "version = \"$ver\";"
  replace "$f" "$old" "$new"
  eval_ok buzz-desktop
}

update_antigravity() {
  PKG=antigravity f=common/nixos/overlays/antigravity-cli.nix
  local cur ver base old_hashes new
  cur=$(file_version "$f")
  ver=$(gh_latest_release google-antigravity/antigravity-cli)
  report "$cur" "$ver" || return 0
  base="https://github.com/google-antigravity/antigravity-cli/releases/download/${ver}"
  mapfile -t old_hashes < <(grep -oP 'hash = "\Ksha256-[^"]+' "$f")
  replace "$f" "version = \"$cur\";" "version = \"$ver\";"
  # hash order in the file: x64 first, arm64 second
  new=$(prefetch_url "$base/agy_cli_linux_x64.tar.gz")
  replace "$f" "${old_hashes[0]}" "$new"
  new=$(prefetch_url "$base/agy_cli_linux_arm64.tar.gz")
  replace "$f" "${old_hashes[1]}" "$new"
  eval_ok antigravity-cli
}

update_pi() {
  PKG=pi f=common/nixos/overlays/pi-coding-agent.nix
  local d=common/nixos/overlays/pi-coding-agent
  local cur ver old new
  cur=$(file_version "$f")
  ver=$(curl -sf https://registry.npmjs.org/@mariozechner/pi-coding-agent/latest | jq -r .version)
  report "$cur" "$ver" || return 0
  replace "$f" "version = \"$cur\";" "version = \"$ver\";"
  replace "$d/package.json" "\"version\": \"$cur\"" "\"version\": \"$ver\""
  replace "$d/package.json" \
    "\"@mariozechner/pi-coding-agent\": \"$cur\"" \
    "\"@mariozechner/pi-coding-agent\": \"$ver\""
  (cd "$d" && nix-shell -p nodejs --run \
    'npm install --package-lock-only --ignore-scripts' >/dev/null)
  log "lockfile rigenerato"
  new=$(nix-shell -p prefetch-npm-deps --run "prefetch-npm-deps $d/package-lock.json" 2>/dev/null | tail -1)
  old=$(grep -oP 'npmDepsHash = "\Ksha256-[^"]+' "$f")
  replace "$f" "$old" "$new"
  eval_ok pi-coding-agent
}

update_qbz() {
  PKG=qbz f=common/nixos/overlays/qbz.nix
  local cur tag ver old new
  cur=$(file_version "$f")
  tag=$(gh_latest_tag vicrodh/qbz v)
  ver="${tag#v}"
  report "$cur" "$ver" || return 0
  new=$(prefetch_github "vicrodh/qbz/$tag")
  old=$(grep -oP 'hash = "\Ksha256-[^"]+' "$f" | head -1)
  replace "$f" "version = \"$cur\";" "version = \"$ver\";"
  replace "$f" "$old" "$new"
  eval_ok qbz
}

update_gitbutler() {
  PKG=gitbutler f=common/nixos/overlays/gitbutler.nix
  local cur tag ver hashes new
  cur=$(file_version "$f")
  tag=$(gh_latest_release gitbutlerapp/gitbutler)
  ver="${tag#release/}"
  report "$cur" "$ver" || return 0
  # hash order in the file: src, cargoDeps, pnpmDeps (values are unique)
  mapfile -t hashes < <(grep -oP '(hash|outputHash) = "\Ksha256-[^"]+' "$f")
  replace "$f" "version = \"$cur\";" "version = \"$ver\";"
  new=$(prefetch_github "gitbutlerapp/gitbutler/$tag")
  replace "$f" "${hashes[0]}" "$new"
  log "src ok, scopro cargoDeps (fetch dei vendor, qualche minuto)"
  replace "$f" "${hashes[1]}" "$FAKE"
  new=$(fod_hash gitbutler.cargoDeps)
  [[ -n "$new" ]] || { log "hash cargoDeps non trovato"; return 1; }
  replace "$f" "$FAKE" "$new"
  log "cargoDeps ok, scopro pnpmDeps"
  replace "$f" "${hashes[2]}" "$FAKE"
  new=$(fod_hash gitbutler.pnpmDeps)
  [[ -n "$new" ]] || { log "hash pnpmDeps non trovato"; return 1; }
  replace "$f" "$FAKE" "$new"
  eval_ok gitbutler
  log "NOTA: hash aggiornati ed eval ok; la compilazione vera (pesante) parte al prossimo nixu"
}

update_vm_curator() {
  PKG=vm-curator f=flake.nix
  local cur tag
  cur=$(grep -oP 'github:mroboff/vm-curator/\K[^"]+' "$f")
  tag=$(gh_latest_release mroboff/vm-curator)
  report "$cur" "$tag" || return 0
  replace "$f" "github:mroboff/vm-curator/$cur" "github:mroboff/vm-curator/$tag"
  nix flake update vm-curator >/dev/null
  log "input rilockato"
  eval_ok vm-curator
}

run() {
  case "$1" in
    buzz) update_buzz ;;
    antigravity) update_antigravity ;;
    pi) update_pi ;;
    qbz) update_qbz ;;
    gitbutler) update_gitbutler ;;
    vm-curator) update_vm_curator ;;
    all)
      for p in buzz antigravity pi qbz vm-curator gitbutler; do run "$p"; done
      ;;
    *)
      echo "uso: $0 [--check] {buzz|antigravity|pi|qbz|gitbutler|vm-curator|all}" >&2
      exit 1
      ;;
  esac
}

run "$TARGET"
[[ $CHECK == 1 ]] || echo "Fatto. Controlla con: git diff (o but diff), poi commit e nixu."
