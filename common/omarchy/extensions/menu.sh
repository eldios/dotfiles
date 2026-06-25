# Omarchy menu user extension.
# Sourced at the end of `omarchy-menu` via $USER_EXTENSIONS hook.
# - Drops Arch-only entries (Install / Remove / Update) from the main menu
# - Replaces upstream's bare theme switcher with a richer Theme submenu that
#   keeps Install/Update/Remove of THEMES (not packages, those are Nix-managed)
# - Overrides theme Install so cloned repos are NOT auto-activated; the user
#   must vet the cloned code before invoking Choose to apply it.

# Clone a theme repo into ~/.config/omarchy/themes/<name> WITHOUT activating it.
# Upstream omarchy-theme-install ends with `omarchy-theme-set`, which is the
# threat: a third-party repo gets executed (mako on-button-left, waybar custom
# modules, hyprland exec, ...) before the user has a chance to read the code.
omarchy_theme_install_safe() {
  local THEMES_DIR="$HOME/.config/omarchy/themes"
  local REPO_URL REPO_PATH THEME_NAME THEME_PATH

  if [[ -z ${1:-} ]]; then
    REPO_URL=$(gum input --placeholder="Git repo URL (https or git@host:org/repo.git)" --header="Theme repo URL")
  else
    REPO_URL="$1"
  fi
  [[ -z $REPO_URL ]] && { echo "No URL provided." >&2; return 1; }

  REPO_PATH="$REPO_URL"
  [[ $REPO_PATH != *"://"* && $REPO_PATH == *:*/* ]] && REPO_PATH="${REPO_PATH#*:}"
  THEME_NAME=$(basename "$REPO_PATH" .git | sed -E 's/^omarchy-//; s/-theme$//' | tr '[:upper:]' '[:lower:]')
  THEME_PATH="$THEMES_DIR/$THEME_NAME"

  if [[ -d $THEME_PATH ]]; then
    echo "Theme directory already exists: $THEME_PATH" >&2
    echo "Remove it first via the 'Remove Theme' menu, then retry." >&2
    return 1
  fi

  mkdir -p "$THEMES_DIR"
  if ! git clone "$REPO_URL" "$THEME_PATH"; then
    echo "git clone failed." >&2
    return 1
  fi

  echo
  printf '\e[1;33m=== Cloned but NOT activated ===\e[0m\n'
  printf '  Path:   %s\n' "$THEME_PATH"
  printf '  Remote: %s\n' "$REPO_URL"
  echo

  # Surface anything that could execute on theme apply, to make the manual
  # review easier. This is a heuristic preview, not a security guarantee.
  printf '\e[1;36mActive-content surface to review:\e[0m\n'
  (
    cd "$THEME_PATH" || exit 0
    find . -path ./.git -prune -o -type f \
      \( -name '*.sh' -o -name '*.bash' -o -name '*.zsh' -o -name '*.fish' \
         -o -name '*.py' -o -name '*.lua' \) -print 2>/dev/null \
      | sed 's|^\./|  script: |'
    grep -lE '^[^#]*\bexec(-once)?\b' hyprland.conf hyprlock.conf 2>/dev/null \
      | sed 's|^|  hypr-exec: |'
    grep -lE '^[^#]*\bon-(button|notified|action)\b.*=' mako.ini 2>/dev/null \
      | sed 's|^|  mako-exec: |'
    grep -rlE '@import\s+url\(\s*["'\'']?https?://' \
         --include='*.css' . 2>/dev/null \
      | sed 's|^\./|  external-css: |'
  ) | sort -u

  echo
  printf '\e[1;32mNext steps:\e[0m\n'
  printf '  1. Review the code: \e[1m%s\e[0m\n' "$THEME_PATH"
  printf '  2. When satisfied, activate it via: Theme > Choose\n'
  printf '     (or: omarchy-theme-set %s)\n' "$THEME_NAME"
  printf '  3. To abort, remove via: Theme > Remove Theme\n'
}
export -f omarchy_theme_install_safe

show_main_menu() {
  go_to_menu "$(menu "Go" "󰀻  Apps\n󰧑  Learn\n󱓞  Trigger\n  Style\n  Setup\n  About\n  System")"
}

# Override upstream's show_theme_menu (which just invokes omarchy-theme-switcher)
# to add theme-management actions. Switcher still reachable via "Choose".
show_theme_menu() {
  case "$(menu "Theme" "󰸌  Choose\n󰸌  Current\n  Copy Themes URL\n󰉉  Install from Git\n  Update Git Themes\n󰭌  Remove Theme")" in
    *Choose*)
      theme=$(omarchy-theme-switcher)
      [[ -n $theme ]] && omarchy-theme-set "$theme"
      ;;
    *Current*)
      notify-send "Current theme" "$(omarchy-theme-current)" -t 2500
      ;;
    *"Copy Themes URL"*)
      printf '%s' "https://manuals.omamix.org/2/the-omarchy-manual/90/extra-themes" | wl-copy
      notify-send "Themes URL copied" "https://manuals.omamix.org/2/the-omarchy-manual/90/extra-themes" -t 3000
      ;;
    *Install*)
      omarchy-launch-floating-terminal-with-presentation omarchy_theme_install_safe
      ;;
    *Update*)
      omarchy-launch-floating-terminal-with-presentation omarchy-theme-update
      ;;
    *Remove*)
      local theme_to_remove
      theme_to_remove="$(find "$HOME/.config/omarchy/themes" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null \
        | sort \
        | omarchy-launch-walker --dmenu --width 360 --minheight 1 --maxheight 420 -p "Remove theme..." || true)"
      [[ -z $theme_to_remove ]] && return 0
      local current
      current="$(omarchy-theme-current)"
      if [[ $theme_to_remove == "$current" ]]; then
        notify-send -u critical "Cannot remove active theme" "$theme_to_remove" -t 3000
        return 0
      fi
      case "$(menu "Confirm" "  No\n  Yes — remove $theme_to_remove")" in
        *Yes*)
          if rm -rf "$HOME/.config/omarchy/themes/$theme_to_remove"; then
            notify-send "Theme removed" "$theme_to_remove" -t 2500
          else
            notify-send -u critical "Remove failed" "$theme_to_remove" -t 4000
          fi
          ;;
      esac
      ;;
  esac
}

# Drop the "edit hypr config" entries: our hyprland config is Nix-managed and
# read-only (~/.config/hypr/*.conf are store symlinks), and the upstream
# entries point at ~/.config/hypr/*.lua paths that don't exist here. The real
# config lives in the dotfiles repo, so we expose a "Dotfiles" entry instead.

# Style menu without the "Hyprland" (looknfeel) editor entry.
show_style_menu() {
  case $(menu "Style" "󰸌  Theme\n󰟵  Unlock\n  Font\n  Background\n󰍜  Waybar\n󰘇  Corners\n󱄄  Screensaver\n  About") in
  *Theme*) show_theme_menu ;;
  *Unlock*) omarchy-launch-walker -m menus:omarchyunlocks --width 800 --minheight 400 ;;
  *Font*) show_font_menu ;;
  *Background*) show_background_menu ;;
  *Corners*) show_style_corners_menu ;;
  *Waybar*) show_waybar_position_menu ;;
  *Screensaver*) show_screensaver_menu ;;
  *About*) show_about_menu ;;
  *) show_main_menu ;;
  esac
}

# Setup menu without the hypr config editors (Monitors/Keybindings/Input);
# "Dotfiles" opens the source repo in $EDITOR instead.
show_setup_menu() {
  local options="  Audio\n  Wifi\n󰂯  Bluetooth\n󱐋  Power Profile\n  System Sleep\n󰊢  Dotfiles\n  Defaults\n󰱔  DNS\n  Security\n  Config"

  case $(menu "Setup" "$options") in
  *Audio*) omarchy-launch-audio ;;
  *Wifi*) omarchy-launch-wifi ;;
  *Bluetooth*) omarchy-launch-bluetooth ;;
  *Power*) show_setup_power_menu ;;
  *System*) show_setup_system_menu ;;
  *Dotfiles*) omarchy-launch-editor "$HOME/dotfiles" ;;
  *Defaults*) show_setup_default_menu ;;
  *DNS*) present_terminal omarchy-setup-dns ;;
  *Security*) show_setup_security_menu ;;
  *Config*) show_setup_config_menu ;;
  *) show_main_menu ;;
  esac
}
