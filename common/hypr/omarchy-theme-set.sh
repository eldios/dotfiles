#!/usr/bin/env bash
#
# Stands in for Omarchy's theme-set. Theming on this system is riso's job:
# the original pipeline copies a theme out of the package tree with its
# permissions attached, and a read-only store poisons the state tree the
# first time. The shell's theme carousel and the helper scripts call this
# name, so riso answers to it.

set -euo pipefail

riso-apply "${1:-}"

# The retints their pipeline ran after a switch, kept because terminals only
# reload on a signal. Anything absent or failing is not the theme's problem.
for helper in omarchy-restart-terminal omarchy-restart-hyprctl omarchy-restart-btop; do
  command -v "$helper" >/dev/null 2>&1 && "$helper" >/dev/null 2>&1 || true
done
