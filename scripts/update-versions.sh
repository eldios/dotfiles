#!/usr/bin/env bash
# Update the custom-packaged versions in this repo: overlay pins (version +
# hashes) and tag-pinned flake inputs. Each package updates atomically, hash
# by hash: everything discovered is written to disk immediately, so a failing
# step never invalidates the hashes already computed.
#
# Usage:
#   scripts/update-versions.sh [--check|--nightly] <package>|all
# Packages: antigravity gitbutler vm-curator omarchy multica
# --check only reports current vs latest, writes nothing.
# --nightly also builds every updated package; a package whose update or
# build fails gets its previous pins back and the run goes on with the next
# one, exiting 1 at the end. The nightly prebuild runs it.
#
# multica follows the release the self-hosted server runs (MULTICA_SERVER,
# its /health commit matched to an upstream tag), not GitHub's latest: the
# daemon and the server share one protocol.
set -euo pipefail
cd "$(dirname "$0")/.."

CHECK=0 NIGHTLY=0
case ${1:-} in
  --check) CHECK=1 && shift ;;
  --nightly) NIGHTLY=1 && shift ;;
esac
TARGET="${1:-all}"
MULTICA_SERVER="${MULTICA_SERVER:-https://ai.vpn.lele.rip}"
# Everything an update writes: restored as a whole when a nightly one fails.
PINNED=(modules/aspects/_overlays flake.nix flake.lock)
FAILED=()

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

server_release() { # -> multica tag whose commit the server reports
  local commit tag
  commit=$(curl -sf --max-time 30 "$MULTICA_SERVER/health" | jq -r '.commit // empty')
  [[ $commit =~ ^[0-9a-f]{40}$ ]] || { log "no commit from $MULTICA_SERVER/health" >&2; return 1; }
  tag=$(curl -sf "https://api.github.com/repos/multica-ai/multica/tags?per_page=100" \
    | jq -r --arg c "$commit" '[.[] | select(.commit.sha == $c) | .name][0] // empty')
  [[ -n $tag ]] || { log "server commit $commit is no release tag" >&2; return 1; }
  echo "$tag"
}

prefetch_url() { nix store prefetch-file --json "$1" | jq -r .hash; }
prefetch_github() { nix flake prefetch --json "github:$1" | jq -r .hash; }

file_version() { grep -oP 'version = "\K[^"]+' "$1" | head -1; }

# Realize a fixed-output derivation carrying $FAKE and return the real hash
# nix reports in the mismatch error; without one, show why the build failed.
fod_hash() { # attr
  local out hash
  out=$(nix build --no-link ".#nixosConfigurations.$HOST.pkgs.$1" 2>&1 || true)
  hash=$(grep -oP 'got:\s+\Ksha256-\S+' <<<"$out" | head -1 || true)
  [[ -n $hash ]] || { tail -n 25 <<<"$out" >&2; return 1; }
  echo "$hash"
}

# Evaluate the package; in a nightly run also build it, so a source that
# no longer compiles or patches keeps the previous pin.
verify() { # attr
  nix eval --raw ".#nixosConfigurations.$HOST.pkgs.$1.drvPath" >/dev/null
  log "$1: eval ok"
  [[ $NIGHTLY == 1 ]] || return 0
  nix build --no-link ".#nixosConfigurations.$HOST.pkgs.$1"
  log "$1: build ok"
}

report() { # current latest -> returns 1 when already up to date
  if [[ "$1" == "$2" ]]; then
    log "already up to date ($1)"
    return 1
  fi
  log "$1 -> $2"
  [[ $CHECK == 1 ]] && return 1
  return 0
}

update_antigravity() {
  PKG=antigravity f=modules/aspects/_overlays/antigravity-cli.nix
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
  verify antigravity-cli
}

update_gitbutler() {
  PKG=gitbutler f=modules/aspects/_overlays/gitbutler.nix
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
  log "src ok, resolving cargoDeps (vendor fetch, a few minutes)"
  replace "$f" "${hashes[1]}" "$FAKE"
  new=$(fod_hash gitbutler.cargoDeps) || { log "cargoDeps hash not found"; return 1; }
  replace "$f" "$FAKE" "$new"
  log "cargoDeps ok, resolving pnpmDeps"
  replace "$f" "${hashes[2]}" "$FAKE"
  new=$(fod_hash gitbutler.pnpmDeps) || { log "pnpmDeps hash not found"; return 1; }
  replace "$f" "$FAKE" "$new"
  verify gitbutler
}

update_multica() {
  PKG=multica f=modules/aspects/_overlays/multica.nix
  local cur tag ver hashes new
  cur=$(file_version "$f")
  tag=$(server_release)
  ver="${tag#v}"
  report "$cur" "$ver" || return 0
  # hash order in the file: src, vendorHash
  mapfile -t hashes < <(grep -oP '(hash|vendorHash) = "\Ksha256-[^"]+' "$f")
  replace "$f" "version = \"$cur\";" "version = \"$ver\";"
  replace "$f" "tag = \"v$cur\";" "tag = \"v$ver\";"
  new=$(prefetch_github "multica-ai/multica/$tag")
  replace "$f" "${hashes[0]}" "$new"
  log "src ok, resolving vendorHash"
  replace "$f" "${hashes[1]}" "$FAKE"
  new=$(fod_hash multica.goModules) || { log "vendorHash not found (check the go.mod postPatch)"; return 1; }
  replace "$f" "$FAKE" "$new"
  log "vendorHash ok, resolving the desktop app's pnpm deps"
  hashes[2]=$(grep -oP 'outputHash = "\Ksha256-[^"]+' "$f")
  replace "$f" "${hashes[2]}" "$FAKE"
  new=$(fod_hash multica-desktop.pnpmDeps) || { log "desktop pnpm hash not found"; return 1; }
  replace "$f" "$FAKE" "$new"
  verify multica
  verify multica-desktop
}

update_omarchy() {
  PKG=omarchy f=flake.nix
  local cur tag
  cur=$(grep -oP 'github:omacom/omarchy/\K[^"]+' "$f")
  tag=$(gh_latest_release omacom/omarchy)
  report "$cur" "$tag" || return 0
  replace "$f" "github:omacom/omarchy/$cur" "github:omacom/omarchy/$tag"
  nix flake update omarchy-quattro >/dev/null
  log "input re-locked"
  verify quickshell
}

update_vm_curator() {
  PKG=vm-curator f=flake.nix
  local cur tag
  cur=$(grep -oP 'github:mroboff/vm-curator/\K[^"]+' "$f")
  tag=$(gh_latest_release mroboff/vm-curator)
  report "$cur" "$tag" || return 0
  replace "$f" "github:mroboff/vm-curator/$cur" "github:mroboff/vm-curator/$tag"
  nix flake update vm-curator >/dev/null
  log "input re-locked"
  verify vm-curator
}

run() {
  case "$1" in
    antigravity) update_antigravity ;;
    gitbutler) update_gitbutler ;;
    vm-curator) update_vm_curator ;;
    omarchy) update_omarchy ;;
    multica) update_multica ;;
    *)
      echo "usage: $0 [--check|--nightly] {antigravity|gitbutler|vm-curator|omarchy|multica|all}" >&2
      exit 1
      ;;
  esac
}

# One package; in a nightly run a failure restores its previous pins instead
# of stopping. set -e stays in force inside the subshell because the
# subshell itself is not tested by a condition.
update() { # package
  [[ $NIGHTLY == 1 ]] || { run "$1"; return; }
  local snap rc
  snap=$(mktemp -d)
  cp -a "${PINNED[@]}" "$snap/"
  set +e
  (set -e; run "$1")
  rc=$?
  set -e
  if [[ $rc != 0 ]]; then
    rm -rf modules/aspects/_overlays
    cp -a "$snap/_overlays" modules/aspects/
    cp -a "$snap/flake.nix" "$snap/flake.lock" .
    FAILED+=("$1")
    PKG=$1 log "update failed, previous pin kept"
  fi
  rm -rf "$snap"
}

if [[ $TARGET == all ]]; then
  for p in antigravity vm-curator omarchy multica gitbutler; do update "$p"; done
else
  update "$TARGET"
fi
if ((${#FAILED[@]})); then
  echo "Failed, previous pins kept: ${FAILED[*]}" >&2
  exit 1
fi
[[ $CHECK == 1 || $NIGHTLY == 1 ]] || echo "Done. Review with: but diff, then commit and switch."
