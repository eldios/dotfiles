# Omarchy menu user extension.
# Sourced at the end of `omarchy-menu` via $USER_EXTENSIONS hook.
# - Drops Arch-only entries (Install / Remove / Update) from the main menu
# - Replaces upstream's bare theme switcher with a richer Theme submenu that
#   keeps Install/Update/Remove of THEMES (not packages, those are Nix-managed)

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
      omarchy-launch-floating-terminal-with-presentation omarchy-theme-install
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
