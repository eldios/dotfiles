{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  walkerPkg = inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # First-run theme seed: pick this if no theme is currently active.
  # Updates as you swap out hyprland-fancy for whatever default suits you.
  defaultTheme = "hyprland-fancy";

  # Re-apply current theme if its expanded artefacts are missing (e.g. after a
  # `nix-collect-garbage` wiped intermediate files or first HM activation).
  ensureCurrentTheme = pkgs.writeShellScript "ensure-current-theme" ''
    set -euo pipefail
    mkdir -p "$HOME/.config/hypr"

    user_themes="$HOME/.config/omarchy/themes"

    # Bootstrap a theme on first run; hyprland.conf sources a stable
    # omarchy-theme.conf that the omarchy-restart-hyprctl override atomically
    # refreshes from current/theme/hyprland.conf on every theme switch.
    if [ ! -f "$HOME/.config/omarchy/current/theme.name" ] || [ ! -d "$HOME/.config/omarchy/current/theme" ]; then
      if [ -d "$user_themes/${defaultTheme}" ]; then
        OMARCHY_THEME_SKIP_BACKGROUND=1 omarchy-theme-set "${defaultTheme}" || true
      fi
    elif [ ! -f "$HOME/.config/omarchy/current/theme/walker.css" ] \
      || [ ! -f "$HOME/.config/omarchy/current/theme/hyprland.conf" ]; then
      current_theme="$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || true)"
      [ -n "$current_theme" ] && OMARCHY_THEME_SKIP_BACKGROUND=1 omarchy-theme-set "$current_theme" || true
    fi

    # Seed omarchy-theme.conf so hyprland.conf's `source =` line always resolves,
    # even before the first omarchy-theme-set runs.
    if [ -f "$HOME/.config/omarchy/current/theme/hyprland.conf" ] \
      && [ ! -f "$HOME/.config/hypr/omarchy-theme.conf" ]; then
      install -m 0644 "$HOME/.config/omarchy/current/theme/hyprland.conf" "$HOME/.config/hypr/omarchy-theme.conf" || true
    fi
    # If still missing (no current theme yet), drop an empty file to silence
    # Hyprland's source= globbing notification at startup.
    [ -f "$HOME/.config/hypr/omarchy-theme.conf" ] || : > "$HOME/.config/hypr/omarchy-theme.conf"
  '';
in {
  home.file = {
    # Walker GTK theme (style.css + layout.xml). Style.css @imports the current
    # theme's walker.css, so palette comes from whichever omarchy theme is active.
    ".config/walker/themes/eldios" = {
      source = ../../../omarchy/default/walker/themes/eldios;
      recursive = true;
    };
  };

  home.activation.seedOmarchyTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${ensureCurrentTheme} || true
  '';
}
# vim: set ts=2 sw=2 et ai list nu
