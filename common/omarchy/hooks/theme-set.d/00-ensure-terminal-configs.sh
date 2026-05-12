#!/usr/bin/env bash
# Ensure terminal config files always exist under current/theme/ so that
# our terminal HM modules (which include them unconditionally) never error
# on a missing path. Empty placeholders fall back to terminal defaults.
set -euo pipefail

theme_dir="$HOME/.config/omarchy/current/theme"
[[ -d "$theme_dir" ]] || exit 0

for f in ghostty.conf alacritty.toml kitty.conf; do
  [[ -f "$theme_dir/$f" ]] || : > "$theme_dir/$f"
done
