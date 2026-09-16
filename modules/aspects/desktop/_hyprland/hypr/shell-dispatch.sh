#!/usr/bin/env bash
#
# Ask whichever shell is running to do something, without the keybinding
# needing to know which one that is.
#
#   shell-dispatch launcher        open the application launcher
#   shell-dispatch run             type a command line and run it
#   shell-dispatch menu            open the main menu
#   shell-dispatch clipboard       clipboard history
#   shell-dispatch emoji           emoji picker
#   shell-dispatch notifications   notification history
#   shell-dispatch lock            lock the session
#   shell-dispatch power           power menu
#   shell-dispatch audio           audio panel
#   shell-dispatch network         network panel
#   shell-dispatch bluetooth       bluetooth panel
#   shell-dispatch theme           theme picker
#   shell-dispatch background      background picker
#   shell-dispatch volume-up       output volume up, with the shell's OSD
#   shell-dispatch volume-down     output volume down
#   shell-dispatch volume-mute     toggle output mute
#   shell-dispatch mic-mute        toggle microphone mute
#   shell-dispatch brightness-up   screen brightness up
#   shell-dispatch brightness-down screen brightness down
#   shell-dispatch which           print the shell it would talk to
#
# Every shell here speaks the same shape, `<cli> ipc call <target> <method>`,
# so this is a translation table rather than a protocol. The hardware keys
# also work with no shell on screen, through wpctl and brightnessctl, only
# without an OSD.

set -uo pipefail

usage() {
  sed -n '3,26p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# The command runner: a prompt that takes a bare command line, not a
# .desktop entry, and runs it through a login shell so aliases in PATH and
# profile variables apply. Omarchy and Noctalia have a text prompt of their
# own; the others get tofi, which lists what is in PATH and still accepts
# whatever was typed.
run_typed() {
  local cmd="$1"
  [ -n "$cmd" ] || return 0
  setsid -f bash -lc "$cmd" >/dev/null 2>&1 </dev/null
}

executables() { compgen -c | sort -u; }

run_with_tofi() {
  run_typed "$(executables | tofi --require-match=false --prompt-text 'Run: ')"
}

# Which shell is running.
#
# Answering its own IPC is the only proof that counts. Matching process names
# is not: several Quickshell processes can be up that are not the shell, and
# one of them is Omarchy's background picker, which looks exactly like it.
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
  else
    echo none
  fi
}

# The hardware keys with no shell to draw an OSD.
none() {
  case "$1" in
    volume-up)       wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    volume-down)     wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    volume-mute)     wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic-mute)        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
    brightness-up)   brightnessctl set 5%+ ;;
    brightness-down) brightnessctl set 5%- ;;
    run)             run_with_tofi ;;
    *)               return 2 ;;
  esac
}

omarchy() {
  case "$1" in
    launcher)        omarchy-menu toggle apps ;;
    run)             run_typed "$(omarchy-menu-input Run)" ;;
    menu)            omarchy-menu toggle ;;
    clipboard)       omarchy-shell shell toggle omarchy.clipboard ;;
    emoji)           omarchy-shell shell toggle omarchy.emojis ;;
    notifications)   omarchy-shell shell toggle omarchy.notifications ;;
    lock)            omarchy-system-lock ;;
    power)           omarchy-menu toggle system ;;
    audio)           omarchy-shell shell toggle omarchy.audio ;;
    network)         omarchy-shell shell toggle omarchy.network ;;
    bluetooth)       omarchy-shell shell toggle omarchy.bluetooth ;;
    theme)           omarchy-menu toggle style.theme ;;
    background)      riso-carousel backgrounds ;;
    # Omarchy's own scripts: they move the level and show its OSD.
    volume-up)       omarchy-audio-output-volume raise ;;
    volume-down)     omarchy-audio-output-volume lower ;;
    volume-mute)     omarchy-audio-output-volume mute-toggle ;;
    mic-mute)        omarchy-audio-input-mute ;;
    brightness-up)   omarchy-brightness-display +5% ;;
    brightness-down) omarchy-brightness-display 5%- ;;
    *)               return 2 ;;
  esac
}

dms() {
  case "$1" in
    launcher|menu)   command dms ipc call spotlight toggle ;;
    # The launcher runs nothing typed; a plugin could, tofi does today.
    run)             run_with_tofi ;;
    clipboard)       command dms ipc call clipboard toggle ;;
    emoji)           command dms ipc call spotlight toggle ;;
    notifications)   command dms ipc call notifications open ;;
    lock)            command dms ipc call lock lock ;;
    power)           command dms ipc call powermenu toggle ;;
    # Quick settings hold audio, network and bluetooth in one panel.
    audio|network|bluetooth) command dms ipc call control-center toggle ;;
    theme)           riso-carousel ;;
    background)      riso-carousel backgrounds ;;
    volume-up)       command dms ipc call audio increment 5 ;;
    volume-down)     command dms ipc call audio decrement 5 ;;
    volume-mute)     command dms ipc call audio mute ;;
    mic-mute)        command dms ipc call audio micmute ;;
    # The empty device argument means the default backlight.
    brightness-up)   command dms ipc call brightness increment 5 "" ;;
    brightness-down) command dms ipc call brightness decrement 5 "" ;;
    *)               return 2 ;;
  esac
}

caelestia() {
  case "$1" in
    launcher)        caelestia-shell ipc call drawers toggle launcher ;;
    # `>` in its launcher lists actions declared in its config, never typed
    # text, so the prompt is tofi's.
    run)             run_with_tofi ;;
    menu)            caelestia-shell ipc call drawers toggle dashboard ;;
    notifications)   caelestia-shell ipc call drawers toggle notifications ;;
    lock)            caelestia-shell ipc call lock lock ;;
    power)           caelestia-shell ipc call drawers toggle session ;;
    # The dashboard carries the quick settings.
    audio|network|bluetooth) caelestia-shell ipc call drawers toggle dashboard ;;
    theme)           riso-carousel ;;
    background)      riso-carousel backgrounds ;;
    # No volume IPC: the shell watches Pipewire and draws its OSD on any
    # change, so the level is moved directly.
    volume-up)       wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
    volume-down)     wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
    volume-mute)     wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    mic-mute)        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
    brightness-up)   caelestia-shell ipc call brightness set +5% ;;
    brightness-down) caelestia-shell ipc call brightness set 5%- ;;
    *)               return 2 ;;
  esac
}

noctalia() {
  case "$1" in
    launcher|menu)   command noctalia msg panel-toggle launcher ;;
    # Its dmenu returns the typed text when nothing in the list matches.
    run)             run_typed "$(executables | command noctalia dmenu -p Run)" ;;
    clipboard)       command noctalia msg panel-toggle clipboard ;;
    emoji)           command noctalia msg panel-toggle launcher ;;
    notifications)   command noctalia msg panel-toggle control-center notifications ;;
    lock)            command noctalia msg session lock ;;
    power)           command noctalia msg panel-toggle session ;;
    audio)           command noctalia msg panel-toggle control-center audio ;;
    network)         command noctalia msg panel-toggle control-center network ;;
    bluetooth)       command noctalia msg panel-toggle control-center bluetooth ;;
    theme)           riso-carousel ;;
    background)      riso-carousel backgrounds ;;
    volume-up)       command noctalia msg volume-up ;;
    volume-down)     command noctalia msg volume-down ;;
    volume-mute)     command noctalia msg volume-mute ;;
    mic-mute)        command noctalia msg mic-mute ;;
    brightness-up)   command noctalia msg brightness-up ;;
    brightness-down) command noctalia msg brightness-down ;;
    *)               return 2 ;;
  esac
}

action="${1:-menu}"
case "$action" in
  -h | --help | help) usage 0 ;;
esac

shell="$(active_shell)"
[[ $action == which ]] && { echo "$shell"; exit 0; }

if ! "$shell" "$action"; then
  status=$?
  if (( status == 2 )); then
    echo "shell-dispatch: $shell has no '$action'" >&2
  fi
  exit "$status"
fi
