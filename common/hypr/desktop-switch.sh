#!/usr/bin/env bash
#
# Swap the desktop shell without leaving Hyprland, and without a rebuild.
#
#   desktop-switch waybar    the pre-Quickshell stack: bar, launcher, notifier
#   desktop-switch omarchy   Omarchy 4, one Quickshell process
#   desktop-switch dms       DankMaterialShell
#   desktop-switch current   which one is running
#   desktop-switch list      which ones are installed
#
# Every stack is installed at once and exactly one runs, which is what makes
# switching a matter of stopping processes rather than rebuilding. The choice
# is remembered, and the session autostart honours it at the next login.
#
# Nix wraps binaries, so their comm is `.name-wrapped` and `pgrep -x name`
# never matches. Every check here matches the path instead.

set -uo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/desktop-stack"

usage() {
  sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

have() { command -v "$1" >/dev/null 2>&1; }

# Match other processes only. Without excluding our own pid and our parents,
# every pattern matches this very command line and each check confirms itself.
running() { pgrep -f "$1" 2>/dev/null | grep -qv "^\($$\|$PPID\)$"; }

# Stop everything any stack may have started, so a switch never leaves two
# bars on screen. Killing what is not running is not an error.
stop_all() {
  local pattern
  for pattern in '/bin/waybar' '/bin/mako' '/bin/swayosd-server' \
    'omarchy-launch-shell' 'quickshell.*/shell' 'qs .*/shell' '/bin/dms'; do
    pkill -f "$pattern" 2>/dev/null
  done
  # Give the compositor a moment to reap the layer surfaces.
  sleep 0.3
}

start_waybar() {
  have waybar || { echo "waybar is not installed" >&2; return 1; }
  waybar >/dev/null 2>&1 &
  have mako && mako >/dev/null 2>&1 &
  have swayosd-server && swayosd-server >/dev/null 2>&1 &
  return 0
}

start_omarchy() {
  have omarchy-launch-shell || { echo "the Omarchy shell is not installed" >&2; return 1; }
  omarchy-launch-shell >/dev/null 2>&1 &
  return 0
}

start_dms() {
  have dms || { echo "dms is not installed" >&2; return 1; }
  dms run >/dev/null 2>&1 &
  return 0
}

current() {
  if running 'omarchy-launch-shell' || running 'quickshell.*/shell'; then
    echo omarchy
  elif running '/bin/dms'; then
    echo dms
  elif running '/bin/waybar'; then
    echo waybar
  else
    echo none
  fi
}

list() {
  have waybar && echo "waybar    installed" || echo "waybar    missing"
  have omarchy-launch-shell && echo "omarchy   installed" || echo "omarchy   missing"
  have dms && echo "dms       installed" || echo "dms       missing"
}

# Re-render the current theme for whichever shell now owns the screen: each
# reads its own format, so the files that were right a second ago are not.
# riso-apply carries the theme and template directories; only the desktop to
# notify differs between stacks.
retheme() {
  local desktop
  have riso-apply || return 0

  case "$1" in
    omarchy) desktop=omarchy ;;
    *) desktop=hyprland ;;
  esac

  riso-apply "" "$desktop" >/dev/null 2>&1 || true
}

case "${1:-current}" in
  -h | --help | help) usage 0 ;;
  current) current; exit 0 ;;
  list) list; exit 0 ;;
esac

target="$1"
case "$target" in
  waybar | omarchy | dms) ;;
  *) echo "desktop-switch: unknown stack '$target'" >&2; usage 1 ;;
esac

if [[ "$(current)" == "$target" ]]; then
  echo "$target is already running"
  exit 0
fi

stop_all
if ! "start_$target"; then
  # Never leave the screen bare: fall back to whatever is installed.
  echo "desktop-switch: could not start $target, falling back" >&2
  start_waybar || start_omarchy || start_dms
  exit 1
fi

echo "$target" >"$STATE"
retheme "$target"
echo "switched to $target"
