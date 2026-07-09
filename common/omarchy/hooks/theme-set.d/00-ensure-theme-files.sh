#!/usr/bin/env bash
# Ensure every theme file our HM modules include unconditionally exists under
# current/theme/. Many upstream omarchy themes ship only a subset (e.g.
# tokyo-night has no waybar.css), which would otherwise break waybar/walker on
# a missing @import. Empty placeholders fall back to each tool's own defaults.
#
# omarchy-theme-set restarts components BEFORE running this hook. Only waybar
# is a persistent GTK @import consumer, so it needs a second restart purely
# when its own waybar.css was just created. On-demand consumers (walker,
# terminals) and tolerant daemons (mako) re-read on next use, so creating
# their placeholders must NOT trigger an extra waybar restart.
set -euo pipefail

theme_dir="$HOME/.config/omarchy/current/theme"
[[ -d "$theme_dir" ]] || exit 0

created_waybar=0
for f in \
  alacritty.toml ghostty.conf kitty.conf rio.toml \
  hyprland.conf hyprlock.conf mako.ini \
  walker.css waybar.css; do
  [[ -f "$theme_dir/$f" ]] || {
    : >"$theme_dir/$f"
    [[ $f == waybar.css ]] && created_waybar=1
  }
done


if [[ $created_waybar -eq 1 ]] && pgrep -f waybar >/dev/null; then
  omarchy-restart-waybar || true
fi
