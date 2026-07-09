# shellcheck shell=bash
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
  case $(menu "Style" "󰸌  Theme\n󰟵  Unlock\n  Font\n  Background\n󰍜  Waybar\n  Aesthetics\n󱄄  Screensaver\n  About") in
  *Theme*) show_theme_menu ;;
  *Unlock*) omarchy-launch-walker -m menus:omarchyunlocks --width 800 --minheight 400 ;;
  *Font*) show_font_menu ;;
  *Background*) show_background_menu ;;
  *Aesthetics*) show_aesthetics_menu ;;
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

# Quick high-impact aesthetic overrides. Default = enforce the theme's choice.
# Backed by omarchy-aesthetic-set; the full config still lives in the nix modules.
show_aesthetics_menu() {
  case $(menu "Aesthetics" "  Rounding\n  Transparency\n  Blur\n  Animations\n  Gaps\n  Shadow\n  Default (all)") in
  *Rounding*) show_aes_rounding_menu ;;
  *Transparency*) show_aes_opacity_menu ;;
  *Blur*) show_aes_blur_menu ;;
  *Animations*) show_aes_anim_menu ;;
  *Gaps*) show_aes_gaps_menu ;;
  *Shadow*) show_aes_shadow_menu ;;
  *"Default (all)"*)
    for k in rounding opacity blur animations gaps shadow waybar; do
      omarchy-aesthetic-set "$k" default
    done
    ;;
  *) show_style_menu ;;
  esac
}

show_aes_rounding_menu() {
  case $(menu "Rounding" "  Sharp (0)\n  Small (6)\n  Medium (10)\n  Large (16)\n  Default (theme)") in
  *Sharp*) omarchy-aesthetic-set rounding 0 ;;
  *Small*) omarchy-aesthetic-set rounding 6 ;;
  *Medium*) omarchy-aesthetic-set rounding 10 ;;
  *Large*) omarchy-aesthetic-set rounding 16 ;;
  *Default*) omarchy-aesthetic-set rounding default ;;
  *) show_aesthetics_menu ;;
  esac
}

show_aes_opacity_menu() {
  case $(menu "Transparency" "  Opaque\n  Light\n  Medium\n  Default (theme)") in
  *Opaque*) omarchy-aesthetic-set opacity 1.0,1.0 ;;
  *Light*) omarchy-aesthetic-set opacity 0.97,0.92 ;;
  *Medium*) omarchy-aesthetic-set opacity 0.92,0.85 ;;
  *Default*) omarchy-aesthetic-set opacity default ;;
  *) show_aesthetics_menu ;;
  esac
}

show_aes_blur_menu() {
  case $(menu "Blur" "  On\n  Off\n  Default (theme)") in
  *On*) omarchy-aesthetic-set blur true ;;
  *Off*) omarchy-aesthetic-set blur false ;;
  *Default*) omarchy-aesthetic-set blur default ;;
  *) show_aesthetics_menu ;;
  esac
}

show_aes_anim_menu() {
  case $(menu "Animations" "  On\n  Off\n  Default (theme)") in
  *On*) omarchy-aesthetic-set animations true ;;
  *Off*) omarchy-aesthetic-set animations false ;;
  *Default*) omarchy-aesthetic-set animations default ;;
  *) show_aesthetics_menu ;;
  esac
}

show_aes_gaps_menu() {
  case $(menu "Gaps" "  None\n  Small\n  Medium\n  Large\n  Default (theme)") in
  *None*) omarchy-aesthetic-set gaps 0,0 ;;
  *Small*) omarchy-aesthetic-set gaps 2,4 ;;
  *Medium*) omarchy-aesthetic-set gaps 4,8 ;;
  *Large*) omarchy-aesthetic-set gaps 8,16 ;;
  *Default*) omarchy-aesthetic-set gaps default ;;
  *) show_aesthetics_menu ;;
  esac
}

show_aes_shadow_menu() {
  case $(menu "Shadow" "  On\n  Off\n  Default (theme)") in
  *On*) omarchy-aesthetic-set shadow true ;;
  *Off*) omarchy-aesthetic-set shadow false ;;
  *Default*) omarchy-aesthetic-set shadow default ;;
  *) show_aesthetics_menu ;;
  esac
}

# Replaces upstream's waybar position menu (omarchy-style-waybar-position is not
# packaged here, and our waybar config is Nix-managed). One Waybar submenu with
# nested Position and Bar-style sub-submenus, both via omarchy-aesthetic-set.
show_waybar_position_menu() {
  case $(menu "Waybar" "󰍜  Position\n󰘇  Bar style\n  Default (theme)") in
  *Position*) show_waybar_pos_submenu ;;
  *"Bar style"*) show_waybar_bar_submenu ;;
  *Default*)
    omarchy-aesthetic-set waybar default
    omarchy-aesthetic-set waybar_position default
    ;;
  *) show_style_menu ;;
  esac
}

show_waybar_pos_submenu() {
  case $(menu "Waybar position" "󰁝  Top\n󰁅  Bottom\n󰁍  Left\n󰁔  Right\n  Default (theme)") in
  *Top*) omarchy-aesthetic-set waybar_position top ;;
  *Bottom*) omarchy-aesthetic-set waybar_position bottom ;;
  *Left*) omarchy-aesthetic-set waybar_position left ;;
  *Right*) omarchy-aesthetic-set waybar_position right ;;
  *Default*) omarchy-aesthetic-set waybar_position default ;;
  *) show_waybar_position_menu ;;
  esac
}

show_waybar_bar_submenu() {
  case $(menu "Waybar bar style" "󰊓  Maximized\n󰘇  Floating\n  Default (theme)") in
  *Maximized*) omarchy-aesthetic-set waybar maximized ;;
  *Floating*) omarchy-aesthetic-set waybar floating ;;
  *Default*) omarchy-aesthetic-set waybar default ;;
  *) show_waybar_position_menu ;;
  esac
}
