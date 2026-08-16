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
# Caelestia repaints from the scheme file it watches; hand it the fragment
# riso just rendered. Harmless when the shell is merely installed.
if command -v caelestia-shell >/dev/null 2>&1; then
  scheme_src="${XDG_STATE_HOME:-$HOME/.local/state}/riso/current/theme/caelestia.json"
  scheme_dst="${XDG_STATE_HOME:-$HOME/.local/state}/caelestia/scheme.json"
  if [ -f "$scheme_src" ]; then
    mkdir -p "$(dirname "$scheme_dst")"
    cp "$scheme_src" "$scheme_dst" 2>/dev/null || true
  fi
fi

bg=$(readlink -f "${XDG_STATE_HOME:-$HOME/.local/state}/riso/current/background" 2>/dev/null || true)
if [ -n "$bg" ]; then
  if pgrep -f 'dms run|dms-shell' >/dev/null 2>&1; then
    dms ipc call wallpaper set "$bg" >/dev/null 2>&1 || true
  fi
  if pgrep -f 'caelestia-shell|quickshell.*caelestia' >/dev/null 2>&1; then
    caelestia-shell ipc call wallpaper set "$bg" >/dev/null 2>&1 || true
  fi
fi
