#!/usr/bin/env bash
#
# Swap the desktop shell without leaving Hyprland, and without a rebuild.
#
#   desktop-switch omarchy   Omarchy 4, one Quickshell process
#   desktop-switch dms       DankMaterialShell
#   desktop-switch caelestia Caelestia
#   desktop-switch noctalia  Noctalia
#   desktop-switch retheme   re-apply the theme to the running shell
#   desktop-switch current   which one is running
#   desktop-switch list      which ones are installed
#
# Every shell is installed at once and exactly one runs, which is what makes
# switching a matter of stopping processes rather than rebuilding. The choice
# is remembered, and the session autostart honours it at the next login.
#
# Processes are started by absolute path and matched by that path, so that
# the running instance can be found and stopped on the next switch.

set -uo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/desktop-stack"

usage() {
  sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

have() { command -v "$1" >/dev/null 2>&1; }

# Absolute path of a command, so what is launched is what can be matched.
where() { command -v "$1" 2>/dev/null; }

running() { pgrep -f "$1" >/dev/null 2>&1; }

# What identifies each shell once it is up. Anchored, so a caller that merely
# mentions one of these names is not mistaken for the process itself. A script
# is anchored at the end because its command line carries the interpreter
# first: "bash /nix/store/.../omarchy-launch-shell".
readonly OMARCHY_SUPERVISOR='/omarchy-launch-shell$'
readonly OMARCHY_SHELL='^quickshell .*-p '
readonly OMARCHY_PATTERN="$OMARCHY_SUPERVISOR|$OMARCHY_SHELL"
readonly DMS_PATTERN='^/[^[:space:]]*/dms run|dms-shell'
readonly CAELESTIA_PATTERN='caelestia-shell|quickshell.*caelestia'
# Anchored on both ends: `noctalia msg ...` invocations carry arguments and
# must not look like the shell itself.
readonly NOCTALIA_PATTERN='^/[^[:space:]]*/\.?noctalia(-wrapped)?$'

# Stop every shell, so a switch never leaves two bars on screen. Killing what
# is not running is not an error.
stop_all() {
  local pattern
  # The supervisor first: it restarts the shell, so killing the shell while it
  # still watches only earns a new one.
  for pattern in "$OMARCHY_SUPERVISOR" "$OMARCHY_SHELL" "$DMS_PATTERN" \
    "$CAELESTIA_PATTERN" "$NOCTALIA_PATTERN"; do
    pkill -f "$pattern" 2>/dev/null
  done
  # Give the compositor a moment to reap the layer surfaces.
  sleep 0.5
}

start_omarchy() {
  local shell
  shell="$(where omarchy-launch-shell)"
  [ -n "$shell" ] || { echo "the Omarchy shell is not installed" >&2; return 1; }

  setsid "$shell" >/dev/null 2>&1 &
  return 0
}

start_caelestia() {
  local shell
  shell="$(where caelestia-shell)"
  [ -n "$shell" ] || { echo "Caelestia is not installed" >&2; return 1; }

  setsid "$shell" -d >/dev/null 2>&1 &
  return 0
}

start_noctalia() {
  local shell
  shell="$(where noctalia)"
  [ -n "$shell" ] || { echo "Noctalia is not installed" >&2; return 1; }

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
  elif running "$CAELESTIA_PATTERN"; then
    echo caelestia
  elif running "$NOCTALIA_PATTERN"; then
    echo noctalia
  else
    echo none
  fi
}

list() {
  have omarchy-launch-shell && echo "omarchy   installed" || echo "omarchy   missing"
  have dms && echo "dms       installed" || echo "dms       missing"
  have caelestia-shell && echo "caelestia installed" || echo "caelestia missing"
  have noctalia && echo "noctalia  installed" || echo "noctalia  missing"
}

# Re-render the current theme for whichever shell now owns the screen: each
# reads its own format, so the files that were right a second ago are not.
# omarchy-theme-set renders through riso and then hands the result to the
# shells that need telling; only the desktop to notify differs between them.
retheme() {
  local desktop
  have omarchy-theme-set || return 0

  case "$1" in
    omarchy) desktop=omarchy ;;
    *) desktop=hyprland ;;
  esac

  omarchy-theme-set "" "$desktop" >/dev/null 2>&1 || true
}

# Answering its own IPC is what makes a shell ready to be handed a theme: one
# started a moment ago has a process but no socket yet, and the handover is
# lost with it. The colour scheme reaches caelestia as a file it watches, so
# it survives the race; the wallpaper is an IPC call, and does not.
ready() {
  case "$1" in
    omarchy)   timeout 1 omarchy-shell shell ping ;;
    caelestia) timeout 1 caelestia-shell ipc call drawers list ;;
    noctalia)  timeout 1 noctalia msg status ;;
    # `dms ipc` alone exits zero with no shell running at all, so the probe
    # has to be a call: reading the wallpaper is the one that only answers
    # for a shell that is up.
    dms)       timeout 1 dms ipc call wallpaper get ;;
    *)         true ;;
  esac >/dev/null 2>&1
}

# Bounded: a shell that never answers must not hold the session's startup.
wait_ready() {
  local waited=0
  while ! ready "$1"; do
    waited=$((waited + 1))
    ((waited >= 40)) && return 1
    sleep 0.5
  done
}

case "${1:-current}" in
  -h | --help | help) usage 0 ;;
  current) current; exit 0 ;;
  list) list; exit 0 ;;
  # Re-apply the theme to the shell already on screen. The session runs this
  # once the shell is up: a shell started a moment ago has no IPC socket yet,
  # so the theme handed over during the switch reaches nobody.
  retheme)
    stack="$(current)"
    wait_ready "$stack"
    retheme "$stack"
    exit 0
    ;;
esac

target="$1"
case "$target" in
  omarchy | dms | caelestia | noctalia) ;;
  *) echo "desktop-switch: unknown shell '$target'" >&2; usage 1 ;;
esac

if [[ "$(current)" == "$target" ]]; then
  echo "$target is already running"
  exit 0
fi

stop_all
if ! "start_$target"; then
  # Never leave the screen bare: fall back to whatever is installed.
  echo "desktop-switch: could not start $target, falling back" >&2
  start_omarchy || start_dms || start_caelestia || start_noctalia
  exit 1
fi

echo "$target" >"$STATE"
# The shell was started a moment ago: hand it the theme only once it can
# take it, or the wallpaper call lands on a socket that is not there yet.
wait_ready "$target"
retheme "$target"
echo "switched to $target"
