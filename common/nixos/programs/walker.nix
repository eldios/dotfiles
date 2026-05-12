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
    };
  };

  # Walker GApplication daemon — autostart at login so first menu invocation
  # is instant (cold start otherwise ~1-2s). Mirrors upstream Omarchy's
  # autostart desktop entry + Restart=always systemd drop-in.
  systemd.user.services.walker = {
    description = "Walker launcher daemon (GApplication service)";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" "elephant.service" ];
    partOf = [ "graphical-session.target" ];
    unitConfig.ConditionEnvironment = "XDG_SESSION_TYPE=wayland";
    serviceConfig = {
      Type = "simple";
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
