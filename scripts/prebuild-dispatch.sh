#!/usr/bin/env bash
# Start the prebuild workflow on Forgejo now instead of waiting for the
# nightly schedule, and print the URL of the run it created.
#
# Token: FORGEJO_TOKEN when set, otherwise tokens.forgejo.agent_token from
# the sops-encrypted secrets.yaml in SECRETS_DIR. It needs the
# write:repository scope on eldios/dotfiles.
#
# Usage:
#   scripts/prebuild-dispatch.sh [ref]   (default: main)
set -euo pipefail

FORGEJO="https://git.casa.lele.rip"
REPO="eldios/dotfiles"
REF="${1:-main}"
SECRETS_DIR="${SECRETS_DIR:-$HOME/go/src/github.com/eldios/secrets}"

if [[ -z ${FORGEJO_TOKEN:-} ]]; then
  FORGEJO_TOKEN=$(sops decrypt --extract '["tokens"]["forgejo"]["agent_token"]' \
    "$SECRETS_DIR/secrets.yaml")
fi

# The token goes through a header file on stdin, never on the command line.
run=$(curl -sSf -X POST \
  -H @- \
  -H 'Content-Type: application/json' \
  -d "$(jq -nc --arg ref "$REF" '{ref: $ref, return_run_info: true}')" \
  "$FORGEJO/api/v1/repos/$REPO/actions/workflows/prebuild.yml/dispatches" \
  <<<"Authorization: token $FORGEJO_TOKEN")

echo "$FORGEJO/$REPO/actions/runs/$(jq -r .run_number <<<"$run")"
