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

  # Switching shells and dispatching keybindings are session tools, so they
  # live in the profile like any other command.
  desktopTools = pkgs.runCommandLocal "desktop-tools" {} ''
    mkdir -p $out/bin
    install -m755 ${../../../hypr/desktop-switch.sh} $out/bin/desktop-switch
    install -m755 ${../../../hypr/shell-dispatch.sh} $out/bin/shell-dispatch
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

  # Re-apply whatever theme is active, or the default on a fresh machine.
  # Paths come from $HOME at run time rather than being baked in, so the same
  # command works when invoked by hand.
  applyTheme = pkgs.writeShellScript "riso-apply-theme" ''
    set -euo pipefail

    state="''${XDG_STATE_HOME:-$HOME/.local/state}/omarchy"
    theme="''${1:-$(cat "$state/current/theme.name" 2>/dev/null || echo "${defaultTheme}")}"

    exec ${lib.getExe pkgs.riso} set "$theme" \
      --themes "${omarchyRoot}/themes" \
      --themes "$HOME/.config/omarchy/themes" \
      --templates "$HOME/.config/omarchy/themed" \
      --templates "${omarchyRoot}/default/themed" \
      --state "$state"
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
    # back instant instead of a rebuild away.
    desktopTools
    pkgs.dms

    # The pre-Quickshell stack, kept whole so it stays a working fallback.
    pkgs.waybar
    pkgs.mako
    pkgs.swayosd
    pkgs.wlogout
    inputs.walker.packages.${pkgs.stdenv.hostPlatform.system}.default

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
    "hypr/hyprland.lua".source = lib.mkForce "${upstream}/config/hypr/hyprland.lua";
    "hypr/bindings.lua".source = ../../../hypr/quattro/bindings.lua;
    "hypr/autostart.lua".source = ../../../hypr/quattro/autostart.lua;
    "hypr/looknfeel.lua".source = ../../../hypr/quattro/looknfeel.lua;
    "hypr/input.lua".source = ../../../hypr/quattro/input.lua;
    "hypr/monitors.lua".text = monitorsLua;

    # The pre-Quickshell config lives under hypr/lua/ and is loaded by the
    # hyprland.lua that hyprland.nix installs. Both are replaced above, so
    # leaving those files in place would only be confusing.
    "hypr/lua/settings.lua".enable = lib.mkForce false;
    "hypr/lua/bindings.lua".enable = lib.mkForce false;
    "hypr/lua/windows.lua".enable = lib.mkForce false;
    "hypr/lua/autostart.lua".enable = lib.mkForce false;
  };

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
  home.activation.applyOmarchyTheme = lib.hm.dag.entryAfter ["seedOmarchyShellConfig"] ''
    $DRY_RUN_CMD ${applyTheme} || true
  '';
}
# vim: set ts=2 sw=2 et ai list nu
