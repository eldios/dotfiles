#!/usr/bin/env bash
# Ensure every theme file our HM modules include unconditionally exists under
# current/theme/. Many upstream omarchy themes ship only a subset (e.g.
# tokyo-night has no waybar.css), which would otherwise break waybar/walker on
# a missing @import. Empty placeholders fall back to each tool's own defaults.
#
# waybar.css additionally needs the background/foreground/accent named colors:
# our waybar style references them, and GTK silently drops declarations using
# an undefined named color, leaving the bar transparent. Missing definitions
# are appended, with values taken from the theme's colors.toml or
# alacritty.toml when available, neutral constants otherwise. Appending only
# undefined names never conflicts with the theme's own definitions.
#
# omarchy-theme-set restarts components BEFORE running this hook. Only waybar
# is a persistent GTK @import consumer, so it needs a second restart purely
# when its own waybar.css just changed. On-demand consumers (walker,
# terminals) and tolerant daemons (mako) re-read on next use, so touching
# their placeholders must NOT trigger an extra waybar restart.
set -euo pipefail

theme_dir="$HOME/.config/omarchy/current/theme"
[[ -d "$theme_dir" ]] || exit 0

waybar_changed=0
for f in \
  alacritty.toml ghostty.conf kitty.conf rio.toml \
  hyprland.conf hyprlock.conf mako.ini \
  walker.css waybar.css; do
  [[ -f "$theme_dir/$f" ]] || {
    : >"$theme_dir/$f"
    [[ $f == waybar.css ]] && waybar_changed=1
  }
done

# First "#rrggbb" (or alacritty-style "0xrrggbb") value assigned to $2 in $1.
theme_color() {
  local v
  v=$(sed -nE "s/^[[:space:]]*$2[[:space:]]*=[[:space:]]*[\"']?(#|0x)([0-9a-fA-F]{6})[\"']?.*/#\2/p" \
    "$1" 2>/dev/null | head -1)
  [[ -n $v ]] && printf '%s' "$v"
}

ensure_waybar_color() {
  local name="$1" fallback="$2" value=""
  grep -q "@define-color $name " "$theme_dir/waybar.css" && return 0
  # append on a fresh line even when the file lacks a trailing newline
  [[ -s "$theme_dir/waybar.css" && $(tail -c1 "$theme_dir/waybar.css" | wc -l) -eq 0 ]] \
    && echo >>"$theme_dir/waybar.css"
  for src in "$theme_dir/colors.toml" "$theme_dir/alacritty.toml"; do
    [[ -f $src ]] && value=$(theme_color "$src" "$name") && break
  done
  # alacritty has no "accent" key; its normal blue is the closest match
  [[ -z $value && $name == accent ]] && value=$(theme_color "$theme_dir/alacritty.toml" "blue") || true
  printf '@define-color %s %s;\n' "$name" "${value:-$fallback}" >>"$theme_dir/waybar.css"
  waybar_changed=1
}

ensure_waybar_color background "#1a1a1a"
ensure_waybar_color foreground "#d0d0d0"
ensure_waybar_color accent "#7aa2f7"

if [[ $waybar_changed -eq 1 ]] && pgrep -f waybar >/dev/null; then
  omarchy-restart-waybar || true
fi
