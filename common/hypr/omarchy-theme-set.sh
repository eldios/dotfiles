#!/usr/bin/env bash
#
# Stands in for Omarchy's theme-set. Theming on this system is riso's job:
# the original pipeline copies a theme out of the package tree with its
# permissions attached, and a read-only store poisons the state tree the
# first time. The shell's theme carousel and the helper scripts call this
# name, so riso answers to it.

set -euo pipefail

riso-apply "${1:-}"

# Terminals only reload on a signal, and the upstream helper sends them with
# killall by name, which never matches a Nix-wrapped binary: signal by
# command line instead. Alacritty watches its imported files by itself, and
# btop's helper uses pkill and works as shipped.
pkill -SIGUSR2 -f '(^|/)ghostty( |$)' 2>/dev/null || true
pkill -SIGUSR1 -f '(^|/)kitty( |$)' 2>/dev/null || true

# Alacritty has no reload signal, and the swap of the theme tree kills the
# watcher on the fragment. Its import chain ends in this stable override
# file: touching it makes every live window re-read the chain and re-arm.
touch "$HOME/.config/riso/overrides/alacritty.toml" 2>/dev/null || true
for helper in omarchy-restart-hyprctl omarchy-restart-btop; do
  command -v "$helper" >/dev/null 2>&1 && "$helper" >/dev/null 2>&1 || true
done

# DMS colors follow the rendered dms.json on their own; the wallpaper needs
# to be handed over.
if pgrep -f 'dms run|dms-shell' >/dev/null 2>&1; then
  bg=$(readlink -f "${XDG_STATE_HOME:-$HOME/.local/state}/riso/current/background" 2>/dev/null || true)
  [ -n "$bg" ] && dms ipc call wallpaper set "$bg" >/dev/null 2>&1 || true
fi
