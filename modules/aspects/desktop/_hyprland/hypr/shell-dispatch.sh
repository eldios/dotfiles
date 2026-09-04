#!/usr/bin/env bash
#
# Ask whichever shell is running to do something, without the keybinding
# needing to know which one that is.
#
#   shell-dispatch launcher      open the application launcher
#   shell-dispatch menu          open the main menu
#   shell-dispatch clipboard     clipboard history
#   shell-dispatch emoji         emoji picker
#   shell-dispatch notifications notification history
#   shell-dispatch lock          lock the session
#   shell-dispatch power         power menu
#   shell-dispatch audio         audio panel
#   shell-dispatch network       network panel
#   shell-dispatch bluetooth     bluetooth panel
#   shell-dispatch theme         theme picker
#   shell-dispatch background    background picker
#   shell-dispatch which         print the shell it would talk to
#
# Every shell here speaks the same shape, `<cli> ipc call <target> <method>`,
# so this is a translation table rather than a protocol.

set -uo pipefail

usage() {
  sed -n '3,19p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# Which shell is running.
#
# Answering its own IPC is the only proof that counts. Matching process names
# is not: several Quickshell processes can be up that are not the shell, and
# one of them is Omarchy's background picker, which looks exactly like it.
#
# Waybar has no IPC to ask, so there the process is all there is.
active_shell() {
  if command -v omarchy-shell >/dev/null 2>&1 &&
    timeout 1 omarchy-shell shell ping >/dev/null 2>&1; then
    echo omarchy
  elif command -v dms >/dev/null 2>&1 &&
    pgrep -f 'dms run|dms-shell' >/dev/null 2>&1; then
    # No harmless IPC probe exists: every dms call acts. The command line is
    # distinctive enough to trust.
    echo dms
  elif command -v caelestia-shell >/dev/null 2>&1 &&
    timeout 1 caelestia-shell ipc call drawers list >/dev/null 2>&1; then
    echo caelestia
  elif command -v noctalia >/dev/null 2>&1 &&
    timeout 1 noctalia msg status >/dev/null 2>&1; then
    # `msg status` only prints shell state, so it doubles as a liveness probe.
    echo noctalia
  elif pgrep -f '/bin/waybar' >/dev/null 2>&1; then
    # Match the path, not the name: Nix wraps binaries, so their comm is
    # `.waybar-wrapped` and `pgrep -x waybar` never fires. desktop-switch
    # starts it by absolute path so that this pattern has something to find.
    echo classic
  else
    echo none
  fi
}

omarchy() {
  case "$1" in
    launcher)      omarchy-menu toggle apps ;;
    menu)          omarchy-menu toggle ;;
    clipboard)     omarchy-shell shell toggle omarchy.clipboard ;;
    emoji)         omarchy-shell shell toggle omarchy.emojis ;;
    notifications) omarchy-shell shell toggle omarchy.notifications ;;
    lock)          omarchy-system-lock ;;
    power)         omarchy-menu toggle system ;;
    audio)         omarchy-shell shell toggle omarchy.audio ;;
    network)       omarchy-shell shell toggle omarchy.network ;;
    bluetooth)     omarchy-shell shell toggle omarchy.bluetooth ;;
    theme)         omarchy-menu toggle style.theme ;;
    background)    riso-carousel backgrounds ;;
    *)             return 2 ;;
  esac
}


dms() {
  case "$1" in
    launcher|menu) command dms ipc call spotlight toggle ;;
    clipboard)     command dms ipc call clipboard toggle ;;
    emoji)         command dms ipc call spotlight toggle ;;
    notifications) command dms ipc call notifications open ;;
    lock)          command dms ipc call lock lock ;;
    power)         command dms ipc call powermenu toggle ;;
    # Quick settings hold audio, network and bluetooth in one panel.
    audio|network|bluetooth) command dms ipc call control-center toggle ;;
    theme)         riso-carousel ;;
    background)    riso-carousel backgrounds ;;
    *)             return 2 ;;
  esac
}

caelestia() {
  case "$1" in
    launcher)      caelestia-shell ipc call drawers toggle launcher ;;
    menu)          caelestia-shell ipc call drawers toggle dashboard ;;
    notifications) caelestia-shell ipc call drawers toggle notifications ;;
    lock)          caelestia-shell ipc call lock lock ;;
    power)         caelestia-shell ipc call drawers toggle session ;;
    # The dashboard carries the quick settings.
    audio|network|bluetooth) caelestia-shell ipc call drawers toggle dashboard ;;
    theme)         riso-carousel ;;
    background)    riso-carousel backgrounds ;;
    *)             return 2 ;;
  esac
}

noctalia() {
  case "$1" in
    launcher|menu) command noctalia msg panel-toggle launcher ;;
    clipboard)     command noctalia msg panel-toggle clipboard ;;
    emoji)         command noctalia msg panel-toggle launcher ;;
    notifications) command noctalia msg panel-toggle control-center notifications ;;
    lock)          command noctalia msg session lock ;;
    power)         command noctalia msg panel-toggle session ;;
    audio)         command noctalia msg panel-toggle control-center audio ;;
    network)       command noctalia msg panel-toggle control-center network ;;
    bluetooth)     command noctalia msg panel-toggle control-center bluetooth ;;
    theme)         riso-carousel ;;
    background)    riso-carousel backgrounds ;;
    *)             return 2 ;;
  esac
}

# The classic stack: separate programs rather than one shell.
classic() {
  case "$1" in
    launcher)      walker -m desktopapplications ;;
    menu)          walker ;;
    clipboard)     walker -m clipboard ;;
    emoji)         walker -m symbols ;;
    notifications) makoctl restore ;;
    lock)          hyprlock ;;
    power)         wlogout ;;
    audio)         pavucontrol ;;
    network)       nm-connection-editor ;;
    bluetooth)     blueman-manager ;;
    theme)         riso-carousel ;;
    background)    riso-carousel backgrounds ;;
    *)             return 2 ;;
  esac
}

action="${1:-menu}"
case "$action" in
  -h | --help | help) usage 0 ;;
esac

shell="$(active_shell)"
[[ $action == which ]] && { echo "$shell"; exit 0; }

if [[ $shell == none ]]; then
  echo "shell-dispatch: no shell is running" >&2
  exit 1
fi

if ! "$shell" "$action"; then
  status=$?
  if (( status == 2 )); then
    echo "shell-dispatch: $shell has no '$action'" >&2
  fi
  exit "$status"
fi
