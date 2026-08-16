#!/usr/bin/env bash
#
# Pick a theme from every one riso can see, and apply it. Works on any
# stack: walker runs in dmenu mode, and its service plus the elephant data
# daemon are brought up on demand when the classic stack is not the one
# running them.

set -euo pipefail

ensure_walker() {
  pgrep -f 'walker --gapplication-service' >/dev/null 2>&1 && return 0
  pgrep -f '/bin/elephant$' >/dev/null 2>&1 || setsid elephant >/dev/null 2>&1 &
  setsid walker --gapplication-service >/dev/null 2>&1 &
  sleep 0.5
}

themes=$(riso theme list 2>/dev/null | cut -f1)
if [ -z "$themes" ]; then
  notify-send "riso" "No themes found" 2>/dev/null || echo "riso: no themes found" >&2
  exit 1
fi

ensure_walker
choice=$(printf '%s\n' "$themes" | walker --dmenu -p 'Theme' || true)
[ -n "$choice" ] || exit 0

# By absolute sibling, not by name: a stale session PATH can still carry a
# root where the original script exists.
"$(dirname "$(readlink -f "$0")")/../bin/omarchy-theme-set" "$choice" 2>/dev/null \
  || omarchy-theme-set "$choice"
