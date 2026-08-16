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
# Processes are started by absolute path and matched by that path. Started by
# bare name, waybar's command line is just "waybar", which no path pattern can
# find: the running instance is then invisible, so it is never stopped and a
# second one is added on every switch.

set -uo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/desktop-stack"

usage() {
  sed -n '3,17p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

have() { command -v "$1" >/dev/null 2>&1; }

# Absolute path of a command, so what is launched is what can be matched.
where() { command -v "$1" 2>/dev/null; }

running() { pgrep -f "$1" >/dev/null 2>&1; }

# What identifies each stack once it is up. Anchored, so a caller that merely
# mentions one of these names is not mistaken for the process itself. A script
# is anchored at the end because its command line carries the interpreter
# first: "bash /nix/store/.../omarchy-launch-shell".
readonly WAYBAR_PATTERN='^/[^[:space:]]*/waybar$'
readonly OMARCHY_SUPERVISOR='/omarchy-launch-shell$'
readonly OMARCHY_SHELL='^quickshell .*-p '
readonly OMARCHY_PATTERN="$OMARCHY_SUPERVISOR|$OMARCHY_SHELL"
readonly DMS_PATTERN='^/[^[:space:]]*/dms run|dms-shell'


# Stop everything any stack may have started, so a switch never leaves two
# bars on screen. Killing what is not running is not an error.
stop_all() {
  local pattern
  # The supervisor first: it restarts the shell, so killing the shell while it
  # still watches only earns a new one.
  for pattern in "$OMARCHY_SUPERVISOR" "$OMARCHY_SHELL" "$DMS_PATTERN" \
    "$WAYBAR_PATTERN" '^/[^[:space:]]*/mako$' '^/[^[:space:]]*/swayosd-server$' \
    '^/[^[:space:]]*/elephant$' '/walker --gapplication-service$'; do
    pkill -f "$pattern" 2>/dev/null
  done
  # Give the compositor a moment to reap the layer surfaces.
  sleep 0.5
}

start_waybar() {
  local bar
  bar="$(where waybar)" || return 1
  [ -n "$bar" ] || { echo "waybar is not installed" >&2; return 1; }

  setsid "$bar" >/dev/null 2>&1 &
  have mako && setsid "$(where mako)" >/dev/null 2>&1 &
  have swayosd-server && setsid "$(where swayosd-server)" >/dev/null 2>&1 &
  # Walker 2.x: the elephant data daemon first, then walker in service mode;
  # a walker invocation without the service is an error, not a window.
  have elephant && setsid "$(where elephant)" >/dev/null 2>&1 &
  if have walker; then
    sleep 0.5
    setsid "$(where walker)" --gapplication-service >/dev/null 2>&1 &
  fi
  return 0
}

start_omarchy() {
  local shell
  shell="$(where omarchy-launch-shell)"
  [ -n "$shell" ] || { echo "the Omarchy shell is not installed" >&2; return 1; }

  setsid "$shell" >/dev/null 2>&1 &
  return 0
}

start_dms() {
  local shell
  shell="$(where dms)"
  [ -n "$shell" ] || { echo "DankMaterialShell is not installed" >&2; return 1; }

  setsid "$shell" run >/dev/null 2>&1 &
  return 0
}

current() {
  # Answering its own IPC is the only proof that counts; the process match is
  # the fallback for the moment between launch and the socket being up.
  if have omarchy-shell && timeout 1 omarchy-shell shell ping >/dev/null 2>&1; then
    echo omarchy
  elif running "$OMARCHY_PATTERN"; then
    echo omarchy
  elif running "$DMS_PATTERN"; then
    echo dms
  elif running "$WAYBAR_PATTERN"; then
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
