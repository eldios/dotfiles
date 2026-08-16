{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  upstream = inputs.omarchy-quattro;
  homeDir = config.home.homeDirectory;

  # Theme applied on first run, when no theme is active yet.
  defaultTheme = "tokyo-night";

  # The tree OMARCHY_PATH points at. Upstream installs it at
  # /usr/share/omarchy from an Arch package; the shell reads its own QML from
  # $OMARCHY_PATH/shell and the scripts resolve through $OMARCHY_PATH/bin, so
  # pointing the variable at the store is all the relocation that is needed.
  #
  # bin/ is taken whole rather than curated: the shell shells out to 77 of
  # those scripts for network, bluetooth, audio, brightness, lock and weather.
  # A missing one is a dead panel, and they are 2 MB of bash.
  omarchyRoot = pkgs.runCommandLocal "omarchy-root" {} ''
    mkdir -p $out
    cp -r ${upstream}/shell ${upstream}/themes ${upstream}/default ${upstream}/config ${upstream}/bin $out/
    chmod -R u+w $out
    patchShebangs $out/bin
  '';

  # The scripts have to be in the profile, not only on the session PATH.
  # home.sessionPath applies at the next login, which leaves a rebuild with
  # neither the old commands nor the new ones until the user logs out.
  omarchyBin = pkgs.runCommandLocal "omarchy-bin" {} ''
    mkdir -p $out/bin
    for script in ${omarchyRoot}/bin/*; do
      ln -s "$script" "$out/bin/$(basename "$script")"
    done
  '';

  # Switching shells, dispatching keybindings and applying a theme are session
  # tools, so they live in the profile like any other command.
  #
  # Each one gets a wrapper that pins OMARCHY_PATH and PATH to the store: these
  # commands run from keybindings, whose environment is whatever the session
  # was started with, and an env keyword only applies at session launch. The
  # store path is the one fact Nix knows better than the environment does.
  desktopTools = pkgs.runCommandLocal "desktop-tools" {} ''
    mkdir -p $out/bin $out/libexec
    install -m755 ${../../../hypr/desktop-switch.sh} $out/libexec/desktop-switch
    install -m755 ${../../../hypr/shell-dispatch.sh} $out/libexec/shell-dispatch
    install -m755 ${risoApply} $out/libexec/riso-apply

    for tool in desktop-switch shell-dispatch riso-apply; do
      {
        echo '#!${pkgs.runtimeShell}'
        echo 'export OMARCHY_PATH=${omarchyRoot}'
        echo 'export RISO_THEMES=${omarchyRoot}/themes'
        echo 'export PATH=${omarchyRoot}/bin:$PATH'
        echo "exec $out/libexec/$tool \"\$@\""
      } > "$out/bin/$tool"
      chmod +x "$out/bin/$tool"
    done
  '';

  # Monitors stay declarative in Nix and are emitted as Lua, so a host keeps
  # describing its layout through wayland.windowManager.hyprland.settings.monitor
  # whichever desktop it runs. Hyprland's string form is
  # "<output>,<mode>,<position>,<scale>".
  monitorLine = spec: let
    parts = lib.splitString "," spec;
    field = index: lib.elemAt parts index;
  in
    if builtins.length parts < 4
    then "-- unparsed monitor spec: ${spec}"
    else
      "hl.monitor({ output = \"${field 0}\", mode = \"${field 1}\", "
      + "position = \"${field 2}\", scale = ${field 3} })";

  monitors = config.wayland.windowManager.hyprland.settings.monitor or [];

  monitorsLua = ''
    -- Generated from wayland.windowManager.hyprland.settings.monitor.
    -- Edit the host's Nix configuration, not this file.
    ${lib.concatMapStringsSep "\n" monitorLine monitors}
  '';

  # Applying a theme means pointing riso at this machine's directories, and the
  # activation, the shell switcher and a hand invocation all need the same
  # ones. One command owns them so the three cannot drift apart.
  #
  #   riso-apply [theme] [desktop]
  #
  # Both arguments are optional: the theme defaults to the one in use, the
  # desktop to whatever riso detects from the session. State lives in riso's
  # own tree; the Omarchy shell reads it through the ~/.local/state/omarchy
  # alias the activation below maintains.
  risoApply = pkgs.writeShellScript "riso-apply" ''
    set -euo pipefail

    state="''${XDG_STATE_HOME:-$HOME/.local/state}/riso"
    theme="''${1:-}"
    [ -n "$theme" ] ||
      theme="$(cat "$state/current/theme.name" 2>/dev/null || echo "${defaultTheme}")"

    desktop=()
    [ -n "''${2:-}" ] && desktop=(--desktop "$2")

    # Themes come from riso's own search path: the wrapper's RISO_THEMES
    # points it at the shipped set, and themes the user installs win over it.
    exec ${lib.getExe pkgs.riso} set "$theme" \
      --templates "$HOME/.config/riso/themed" \
      --templates "${omarchyRoot}/default/themed" \
      "''${desktop[@]}"
  '';

  # Upstream's hyprland.lua resolves Omarchy through $OMARCHY_PATH and falls
  # back to /usr/share/omarchy. The display manager starts the session without
  # reading the profile, so the variable is absent, the fallback does not exist
  # here, and the failing dofile aborts the whole config: no bindings, no
  # autostart. The store path is known at build time, so nothing below depends
  # on the environment. envs.lua exports it again for child processes.
  hyprlandLua = ''
    local home = os.getenv("HOME")

    package.path = home .. "/.config/?.lua;"
      .. home .. "/.local/state/?.lua;"
      .. "${omarchyRoot}/?.lua;"
      .. package.path

    -- Their shell and its scripts resolve themselves through OMARCHY_PATH and
    -- expect their own bin/ on PATH. Only their envs.lua sets those, and it is
    -- not loaded here, so declare them: without OMARCHY_PATH the shell starts
    -- with an empty -p argument and dies.
    hl.env("OMARCHY_PATH", "${omarchyRoot}")
    hl.env("PATH", "${omarchyRoot}/bin:" .. (os.getenv("PATH") or ""))

    -- The `o.*` helper layer only. None of their default bindings or settings
    -- are loaded: every key and every rule in this session comes from the
    -- files below.
    require("default.hypr.helpers")

    require("hypr.lua.monitors")
    require("hypr.lua.settings")
    require("hypr.lua.bindings")
    require("hypr.lua.windows")
    require("hypr.lua.autostart")

    -- The theme riso renders, then hand-written overrides; both optional.
    pcall(require, "riso.current.theme.hyprland")
    pcall(require, "riso.overrides.hypr")
  '';
in {
  home.packages = [
    # The desktop shell itself. Upstream builds against quickshell-git; 0.3.0
    # is what nixpkgs carries, and only `quickshell kill` is known to differ,
    # which affects omarchy-restart-shell rather than the running shell.
    pkgs.quickshell

    # Renders themes into the files the shell reads.
    pkgs.riso

    # The commands the shell and the menus call out to.
    omarchyBin

    # Switching between shells at runtime only works if they are all here.
    # Exactly one runs; having the others installed is what makes falling
    # back instant instead of a rebuild away. Waybar, mako and hyprlock come
    # from their own modules, imported next to this one, so the classic stack
    # is configured rather than merely present.
    desktopTools
    inputs.dank-material-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.swayosd
    pkgs.wlogout
    inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default

    # What shell-dispatch opens for the network and bluetooth panels when the
    # classic stack is running.
    pkgs.networkmanagerapplet
    pkgs.blueman

    # omarchy-notification-send resolves notify-send from PATH. Low priority
    # because pcloud ships its own libnotify.so and would otherwise collide.
    (lib.lowPrio pkgs.libnotify)
  ];

  home.sessionVariables = {
    OMARCHY_PATH = "${omarchyRoot}";
  };

  # Upstream's env-bootstrap prepends this whenever OMARCHY_PATH is not the
  # packaged location, which is exactly our case.
  home.sessionPath = ["${omarchyRoot}/bin"];

  # Hyprland configuration follows upstream's layering rather than replacing
  # it: hyprland.lua bootstraps the Lua path, loads Omarchy's defaults, then
  # loads these five files. Defaults improve with each release without
  # rewriting anything here, which is the whole point of the arrangement.
  xdg.configFile = {
    # This module owns the entrypoint because only it knows the helper
    # layer's store path; the modules it loads come from hyprland.nix.
    "hypr/hyprland.lua".source = pkgs.writeText "hyprland.lua" hyprlandLua;
    "hypr/lua/monitors.lua".text = monitorsLua;
  };

  # riso's tree is the source of truth; ~/.local/state/omarchy is an alias
  # for the one consumer that cannot move, the Omarchy shell and its scripts,
  # which hardcode that location. A tree the old pipeline wrote is migrated
  # into riso's on first switch, so the active theme and the ownership
  # registry survive the move.
  home.activation.migrateStateToRiso = lib.hm.dag.entryAfter ["writeBoundary"] ''
    state="${homeDir}/.local/state"
    if [ -d "$state/omarchy" ] && [ ! -L "$state/omarchy" ]; then
      if [ ! -e "$state/riso" ]; then
        $DRY_RUN_CMD mv "$state/omarchy" "$state/riso"
      else
        $DRY_RUN_CMD mv "$state/omarchy" "$state/omarchy.pre-riso.bak"
      fi
    fi
    $DRY_RUN_CMD mkdir -p "$state/riso"
    $DRY_RUN_CMD ln -sfn "$state/riso" "$state/omarchy"
  '';

  # shell.json holds the bar layout and is rewritten by the shell whenever a
  # widget is added or the bar is dragged to another edge, so it must be a real
  # file. Seed it once and leave it alone afterwards.
  home.activation.seedOmarchyShellConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "${homeDir}/.config/omarchy/shell.json" ]; then
      $DRY_RUN_CMD mkdir -p "${homeDir}/.config/omarchy"
      $DRY_RUN_CMD install -m 0644 ${upstream}/config/omarchy/shell.json \
        "${homeDir}/.config/omarchy/shell.json"
    fi
  '';

  # Re-render on every activation: a nixpkgs bump or a theme edit changes the
  # templates, and the generated files are not tracked anywhere else.
  home.activation.applyOmarchyTheme = lib.hm.dag.entryAfter ["seedOmarchyShellConfig" "migrateStateToRiso"] ''
    $DRY_RUN_CMD ${desktopTools}/bin/riso-apply || true
  '';
}
# vim: set ts=2 sw=2 et ai list nu
