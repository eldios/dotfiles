{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  upstream = inputs.omarchy;
  homeDir = config.home.homeDirectory;
  walkerPkg = inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Scripts vendored verbatim from upstream omarchy (no edits).
  # Sourced from github:basecamp/omarchy via flake input.
  vendoredBin = [
    # Theme management
    "omarchy-theme-set"
    "omarchy-theme-set-templates"
    "omarchy-theme-list"
    "omarchy-theme-current"
    "omarchy-theme-install"
    "omarchy-theme-update"
    "omarchy-theme-remove"
    "omarchy-theme-bg-set"
    "omarchy-theme-bg-next"
    "omarchy-theme-bg-install"
    "omarchy-theme-bg-cache"
    "omarchy-theme-bg-switcher"
    "omarchy-theme-switcher"
    "omarchy-theme-colors-from-alacritty"
    "omarchy-menu-images"

    # Launchers
    "omarchy-launch-browser"
    "omarchy-launch-editor"
    # omarchy-launch-editor execs this for TUI editors ($EDITOR=nvim);
    # without it every "edit config" menu entry silently does nothing.
    "omarchy-launch-tui"
    "omarchy-launch-webapp"
    "omarchy-launch-or-focus"
    "omarchy-launch-or-focus-tui"
    "omarchy-launch-or-focus-webapp"

    # Menu
    "omarchy-menu"
    "omarchy-menu-input"
    "omarchy-menu-select"
    "omarchy-menu-keybindings"
    "omarchy-menu-file"
    "omarchy-menu-share"

    # Capture
    "omarchy-capture-screenshot"
    "omarchy-capture-screenrecording"
    "omarchy-capture-text"

    # System / cmd
    "omarchy-system-lock"
    "omarchy-system-wake"
    "omarchy-cmd-present"
    "omarchy-cmd-missing"
    "omarchy-cmd-terminal-cwd"

    # Restart / refresh (graceful no-op if target app missing).
    # restart-walker/waybar/swayosd are no longer shipped upstream; we supply
    # them via `overrides` below, so they must NOT be vendored (no source file).
    "omarchy-restart-hyprctl"
    "omarchy-restart-terminal"
    "omarchy-restart-btop"
    "omarchy-restart-opencode"
    "omarchy-restart-helix"
    "omarchy-refresh-config"

    # Per-app theme appliers (invoked by omarchy-theme-set, exit 0 if app absent)
    "omarchy-theme-set-foot"
    "omarchy-theme-set-gnome"
    "omarchy-theme-set-browser"
    "omarchy-theme-set-vscode"
    "omarchy-theme-set-obsidian"
    "omarchy-theme-set-keyboard"
    "omarchy-theme-set-keyboard-asus-rog"
    "omarchy-theme-set-keyboard-f16"

    # Toggle infrastructure (referenced by theme-set-vscode and others)
    "omarchy-toggle-enabled"

    # Notification helpers
    "omarchy-notification-dismiss"
    "omarchy-notification-send"

    # Hooks
    "omarchy-hook"
    "omarchy-hook-install"

    # Misc
    "omarchy-show-logo"
    "omarchy-show-done"
    "omarchy-font-current"
    "omarchy-font-list"
    "omarchy-font-set"
  ];

  # Override upstream scripts that need Nix-specific adaptations.
  # These override the vendored copy by being installed last in $out/bin.
  overrides = {
    # Generator behind the menu's Aesthetics overrides.
    "omarchy-aesthetic-set" =
      pkgs.writeShellScript "omarchy-aesthetic-set"
        (builtins.readFile ../../../omarchy/bin/omarchy-aesthetic-set);

    # Upstream pgrep's for `elephant`; Nix wraps it as `.elephant-wrapped`,
    # so we go through systemctl to avoid spawning orphan daemons.
    "omarchy-launch-walker" = pkgs.writeShellScript "omarchy-launch-walker" ''
      set -euo pipefail

      if ! ${pkgs.systemd}/bin/systemctl --user is-active --quiet elephant.service; then
        ${pkgs.systemd}/bin/systemctl --user start elephant.service || true
      fi

      if ! ${pkgs.procps}/bin/pgrep -f "walker --gapplication-service" >/dev/null 2>&1; then
        ${pkgs.util-linux}/bin/setsid env GSK_RENDERER=cairo ${walkerPkg}/bin/walker --gapplication-service >/dev/null 2>&1 &
      fi

      exec env GSK_RENDERER=cairo ${walkerPkg}/bin/walker --width 644 --maxheight 300 --minheight 300 "$@"
    '';

    # Upstream uses xdg-terminal-exec with --app-id=org.omarchy.terminal.
    # We invoke ghostty directly with the same class for windowrule consistency.
    "omarchy-launch-floating-terminal-with-presentation" = pkgs.writeShellScript "omarchy-launch-floating-terminal-with-presentation" ''
      set -euo pipefail
      cmd="$*"
      [[ -n "$cmd" ]] || { echo "Usage: omarchy-launch-floating-terminal-with-presentation <cmd>" >&2; exit 1; }
      exec ${pkgs.util-linux}/bin/setsid ${pkgs.ghostty}/bin/ghostty \
        --class=org.omarchy.terminal \
        --title=Omarchy \
        --window-width=130 \
        --window-height=32 \
        -e ${pkgs.bash}/bin/bash -lc \
        "omarchy-show-logo 2>/dev/null || true; $cmd; rc=\$?; if (( rc != 130 )); then ${pkgs.coreutils}/bin/printf '\n  \e[1;32m✔ Done\e[0m  '; read -r -p '(press Enter to close)'; fi"
    '';

    # Upstream `omarchy-restart-terminal` `touch`es alacritty.toml which is a
    # read-only Nix store symlink in our setup. Skip alacritty; keep kitty/ghostty
    # SIGUSR reload paths (those work on running instances regardless).
    "omarchy-restart-terminal" = pkgs.writeShellScript "omarchy-restart-terminal" ''
      if ${pkgs.procps}/bin/pgrep -x kitty >/dev/null; then
        ${pkgs.procps}/bin/pkill -USR1 kitty >/dev/null || true
      fi
      if ${pkgs.procps}/bin/pgrep -x ghostty >/dev/null; then
        ${pkgs.procps}/bin/pkill -USR2 ghostty >/dev/null || true
      fi
    '';

    # Upstream uses `uwsm-app -- waybar` which we shim. Use absolute waybar path
    # and `-f` (not `-x`) since Nix wraps the binary as `.waybar-wrapped` and
    # `-x` would never match. SIGTERM first (graceful), then setsid spawn.
    # Atomic install of current/theme/hyprland.conf into a stable file under
    # ~/.config/hypr/, then reload. We source the stable file (omarchy-theme.conf)
    # from hyprland.conf because sourcing current/theme/hyprland.conf directly
    # triggers a transient "source= globbing error: found no match" notification
    # during omarchy-theme-set's `rm -rf current && mv next current` window.
    "omarchy-restart-hyprctl" = pkgs.writeShellScript "omarchy-restart-hyprctl" ''
      src="$HOME/.config/omarchy/current/theme/hyprland.conf"
      dst="$HOME/.config/hypr/omarchy-theme.conf"
      [[ -f "$src" ]] && ${pkgs.coreutils}/bin/install -m 0644 "$src" "$dst" 2>/dev/null || true
      ${pkgs.hyprland}/bin/hyprctl reload >/dev/null 2>&1 || true
    '';

    # No-op if swayosd-server unit doesn't exist (we don't ship swayosd).
    # Upstream's script unconditionally enables the unit and prints errors.
    "omarchy-restart-swayosd" = pkgs.writeShellScript "omarchy-restart-swayosd" ''
      ${pkgs.systemd}/bin/systemctl --user list-unit-files swayosd-server.service >/dev/null 2>&1 || exit 0
      ${pkgs.systemd}/bin/systemctl --user daemon-reload
      ${pkgs.systemd}/bin/systemctl --user stop swayosd-server.service 2>/dev/null || true
      ${pkgs.procps}/bin/pkill -f swayosd-server 2>/dev/null || true
      ${pkgs.systemd}/bin/systemctl --user reset-failed swayosd-server.service 2>/dev/null || true
      ${pkgs.systemd}/bin/systemctl --user enable --now swayosd-server.service 2>/dev/null || true
    '';

    "omarchy-restart-waybar" = pkgs.writeShellScript "omarchy-restart-waybar" ''
      # Match "/bin/waybar" (the binary path), not just "waybar" (would match
      # our own script `omarchy-restart-waybar` and kill self mid-execution).
      ${pkgs.procps}/bin/pkill -f "/bin/waybar" >/dev/null 2>&1 || true
      sleep 0.3
      ${pkgs.util-linux}/bin/setsid ${pkgs.waybar}/bin/waybar >/dev/null 2>&1 &
    '';

    # Upstream uses swaybg exclusively; we prefer awww (transitions, daemon-based)
    # if awww-daemon is up — fall back to swaybg otherwise. Matches our setup
    # where variety + awww manage wallpapers.
    "omarchy-theme-bg-set" = pkgs.writeShellScript "omarchy-theme-bg-set" ''
      set -euo pipefail
      [[ -n "''${1:-}" ]] || { echo "Usage: omarchy-theme-bg-set <path-to-image>" >&2; exit 1; }
      background="$(${pkgs.coreutils}/bin/realpath "$1")"
      [[ -f "$background" ]] || { echo "File does not exist: $background" >&2; exit 1; }

      link="$HOME/.config/omarchy/current/background"
      ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$link")"
      ${pkgs.coreutils}/bin/ln -nsf "$background" "$link"

      if ${pkgs.procps}/bin/pgrep -x awww-daemon >/dev/null 2>&1; then
        ${pkgs.awww}/bin/awww img "$link" --transition-type fade >/dev/null 2>&1 || true
      else
        ${pkgs.procps}/bin/pkill -x swaybg >/dev/null 2>&1 || true
        ${pkgs.util-linux}/bin/setsid ${pkgs.swaybg}/bin/swaybg -i "$link" -m fill >/dev/null 2>&1 &
      fi
    '';

    # Local convenience wrappers not present upstream (niri keybinds use them).
    "omarchy-launch-apps" = pkgs.writeShellScript "omarchy-launch-apps" ''
      exec omarchy-launch-walker "$@"
    '';
    "omarchy-launch-run" = pkgs.writeShellScript "omarchy-launch-run" ''
      exec omarchy-launch-walker -m runner "$@"
    '';
    "omarchy-launch-files" = pkgs.writeShellScript "omarchy-launch-files" ''
      exec omarchy-launch-walker -m finder "$@"
    '';
    "omarchy-launch-windows" = pkgs.writeShellScript "omarchy-launch-windows" ''
      exec omarchy-launch-walker -m windows "$@"
    '';

    # Toggle no_dim + no_blur + opaque on the active Hyprland window. State
    # per-window address lives in XDG_RUNTIME_DIR — flip set/unset each call.
    # NOTE: setprop window selectors require the `address:` prefix; passing the
    # raw `0x...` falls through to class-regex matching and silently no-ops.
    "omarchy-window-undim-blur-toggle" = pkgs.writeShellScript "omarchy-window-undim-blur-toggle" ''
      set -euo pipefail
      addr="$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.address')"
      [[ -n "$addr" && "$addr" != "null" ]] || exit 0
      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/omarchy-undim-blur"
      ${pkgs.coreutils}/bin/mkdir -p "$state_dir"
      flag="$state_dir/''${addr#0x}"
      if [[ -f "$flag" ]]; then
        ${pkgs.hyprland}/bin/hyprctl --batch "dispatch setprop address:$addr no_dim unset ; dispatch setprop address:$addr no_blur unset ; dispatch setprop address:$addr opaque unset" >/dev/null
        ${pkgs.coreutils}/bin/rm -f "$flag"
      else
        ${pkgs.hyprland}/bin/hyprctl --batch "dispatch setprop address:$addr no_dim 1 ; dispatch setprop address:$addr no_blur 1 ; dispatch setprop address:$addr opaque 1" >/dev/null
        : > "$flag"
      fi
    '';
  };

  # Arch-specific commands the upstream scripts/menu may invoke. Shimmed to
  # no-op + notification — Nix handles package management declaratively.
  archShims = [
    "omarchy-pkg-add"
    "omarchy-pkg-remove"
    "omarchy-pkg-aur-add"
    "omarchy-pkg-aur-remove"
    "omarchy-update"
  ];

  archShimScript = name: pkgs.writeShellScript name ''
    set -euo pipefail
    ${pkgs.libnotify}/bin/notify-send -u low \
      "Not available on NixOS" \
      "${name} → manage packages via Nix configuration" \
      -t 3000
    exit 1
  '';

  # uwsm-app shim. Upstream wraps spawns in `uwsm-app -- <cmd>` to put them in
  # a proper systemd scope under a UWSM-managed session. We don't run UWSM, so
  # strip the wrapper and exec the command directly. Used by restart-waybar,
  # launch-browser, launch-editor, launch-webapp, restart-app, and others.
  uwsmShim = pkgs.writeShellScript "uwsm-app" ''
    [[ "''${1:-}" == "--" ]] && shift
    exec "$@"
  '';

  # Assemble the bin tree: vendored first, overrides + shims last (they win).
  # Patches at build time:
  #   1. Shebangs `#!/bin/bash` → Nix bash (NixOS has no /bin/bash by default)
  #   2. `pgrep -x <name>` → `pgrep -f <name>` (Nix wraps binaries so their
  #      comm is `.<name>-wrapped`; `-x` matches exact comm and always fails)
  #   3. `pkill -x <name>` → `pkill -f <name>` (same reason)
  omarchyBin = pkgs.runCommand "omarchy-bin" { } ''
    mkdir -p $out/bin
    ${lib.concatMapStringsSep "\n" (s: ''
      ${pkgs.gnused}/bin/sed -e '1s|^#!/bin/bash|#!${pkgs.bash}/bin/bash|' \
                            -e '1s|^#! */bin/bash|#!${pkgs.bash}/bin/bash|' \
                            -e 's|pgrep -x |pgrep -f |g' \
                            -e 's|pkill -x |pkill -f |g' \
                            -e 's|pkill -9 -x |pkill -9 -f |g' \
                            ${upstream}/bin/${s} > $out/bin/${s}
      chmod 0755 $out/bin/${s}
    '') vendoredBin}
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (n: v: ''
      install -m 0755 ${v} $out/bin/${n}
    '') overrides)}
    ${lib.concatMapStringsSep "\n" (s: ''
      install -m 0755 ${archShimScript s} $out/bin/${s}
    '') archShims}
    install -m 0755 ${uwsmShim} $out/bin/uwsm-app
  '';
in
{
  home.packages = [
    omarchyBin
    # Required by upstream omarchy-menu-images (Qt QML selector + socket IPC).
    pkgs.quickshell
    pkgs.socat
  ];

  # Deploy upstream support trees verbatim so vendored scripts can find them.
  home.file = {
    ".local/share/omarchy/default" = {
      source = "${upstream}/default";
      recursive = true;
    };
    ".local/share/omarchy/config" = {
      source = "${upstream}/config";
      recursive = true;
    };
    ".local/share/omarchy/logo.txt".source = "${upstream}/logo.txt";

    # User menu extension: removes Arch-only entries (Install/Remove/Update)
    # from omarchy-menu without touching the upstream script.
    ".config/omarchy/extensions/menu.sh".source =
      ../../../omarchy/extensions/menu.sh;

    # Theme-set hooks: run after every `omarchy-theme-set`. Fill in config
    # gaps so incomplete upstream themes (which often omit waybar.css,
    # walker.css, terminal configs, etc.) don't break the modules that
    # include those files unconditionally.
    ".config/omarchy/hooks/theme-set.d/00-ensure-theme-files.sh" = {
      source = ../../../omarchy/hooks/theme-set.d/00-ensure-theme-files.sh;
      executable = true;
    };
  };

  # Override layer for omarchy-aesthetic-set: writable, not Nix-managed, so the
  # hypr `source` and waybar `@import` never reference a missing file.
  home.activation.omarchyAestheticOverrides =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      d="$HOME/.config/omarchy/overrides"
      $DRY_RUN_CMD mkdir -p "$d"
      for f in state hypr.conf waybar.css; do
        [ -e "$d/$f" ] || $DRY_RUN_CMD touch "$d/$f"
      done
      # waybar includes this as config: it must be valid JSON, and the seed
      # must match the bar's default look (top, 32px, no margin).
      [ -e "$d/waybar-config.json" ] || echo '{ "position": "top", "height": 32, "margin-top": 0, "margin-bottom": 0, "margin-left": 0, "margin-right": 0 }' >"$d/waybar-config.json"
    '';

  home.sessionVariables = {
    OMARCHY_PATH = "${homeDir}/.local/share/omarchy";
  };
}

# vim: set ts=2 sw=2 et ai list nu
