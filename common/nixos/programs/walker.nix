{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  elephantPkg = inputs.elephant.packages.${system}.elephant;
  providersPkg = inputs.elephant.packages.${system}.elephant-providers;
  walkerPkg = inputs.walker.packages.${system}.default;

  # Combine elephant binary + providers under one prefix, wrap PATH so the
  # daemon can spawn helpers (bash for desktop entries, wl-clipboard, qalc,
  # imagemagick, bluetoothctl) from a known location.
  elephantCombined = pkgs.stdenv.mkDerivation {
    pname = "elephant-with-providers";
    version = "combined";
    dontUnpack = true;

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      mkdir -p $out/bin $out/lib/elephant
      cp ${elephantPkg}/bin/elephant $out/bin/
      cp -r ${providersPkg}/lib/elephant/providers $out/lib/elephant/
    '';

    postFixup = ''
      wrapProgram $out/bin/elephant \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [
          bash
          wl-clipboard
          libqalculate
          imagemagick
          bluez
        ])} \
        --suffix PATH : /run/current-system/sw/bin:/etc/profiles/per-user/eldios/bin:/run/wrappers/bin
    '';
  };

  # elephant is Type=simple, so `After=elephant.service` only waits for the
  # process to exec — not for its IPC socket to accept connections. Walker
  # racing into that window tries to auto-spawn elephant; if that fails it
  # exits with "Please install elephant.", triggering a Restart=always storm
  # whose overlapping instances collide on the dev.benz.walker bus name.
  # Also gate on the Wayland socket so walker never starts compositor-less
  # (would exit "Lost connection to Wayland compositor").
  waitForWalkerDeps = pkgs.writeShellScript "wait-for-walker-deps" ''
    rt="''${XDG_RUNTIME_DIR}"
    wl="$rt/''${WAYLAND_DISPLAY:-wayland-1}"
    sock="$rt/elephant/elephant.sock"
    i=0
    while [ "$i" -lt 100 ]; do
      [ -S "$wl" ] && [ -S "$sock" ] && exit 0
      ${pkgs.coreutils}/bin/sleep 0.1
      i=$((i + 1))
    done
    # Fall through after ~10s: walker can still spawn elephant itself now
    # that the binary is on its PATH (see `path` below).
    exit 0
  '';
in
{
  environment.systemPackages = [
    walkerPkg
    elephantCombined
  ];

  environment.sessionVariables = {
    ELEPHANT_PROVIDER_DIR = "${elephantCombined}/lib/elephant/providers";
  };

  systemd.user.services.elephant = {
    description = "Elephant launcher backend (Walker provider daemon)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    # Only on Wayland sessions (walker/elephant are wlr-layer-shell clients
    # that crash-loop on X11). i3 fallback session stays clean.
    unitConfig.ConditionEnvironment = "XDG_SESSION_TYPE=wayland";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${elephantCombined}/bin/elephant";
      Restart = "on-failure";
      RestartSec = 3;
    };
    environment = {
      ELEPHANT_PROVIDER_DIR = "${elephantCombined}/lib/elephant/providers";
      # The `runner` provider stat()s every $PATH entry; the systemd-default
      # user PATH appends nonexistent <store>/sbin dirs, spamming "stat ...:
      # no such file or directory". Pin a clean PATH of real launchable dirs
      # (the elephant wrapper still prefixes its own helper tools on top).
      # mkForce: NixOS' systemd-user module defines environment.PATH itself
      # at the same priority, so a plain assignment is a conflicting def.
      PATH = lib.mkForce "/run/current-system/sw/bin:/etc/profiles/per-user/eldios/bin:/run/wrappers/bin";
    };
  };

  # Walker GApplication daemon — autostart at login so first menu invocation
  # is instant (cold start otherwise ~1-2s). Mirrors upstream Omarchy's
  # autostart desktop entry + Restart=always systemd drop-in.
  systemd.user.services.walker = {
    description = "Walker launcher daemon (GApplication service)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" "elephant.service" ];
    wants = [ "elephant.service" ];
    partOf = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "XDG_SESSION_TYPE=wayland";
    # Walker auto-spawns elephant when its socket isn't reachable; without the
    # binary on PATH that fallback fails with "Please install elephant.".
    path = [ elephantCombined ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${waitForWalkerDeps}";
      ExecStart = "${walkerPkg}/bin/walker --gapplication-service";
      Restart = "always";
      RestartSec = 2;
    };
    environment = {
      GSK_RENDERER = "cairo";
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
