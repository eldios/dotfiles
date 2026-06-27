# Overlay: fix gemini-cli launcher/runtime.
#
# gemini-cli-nix's package.nix wraps node with `.../gemini-cli/dist/index.js`,
# but current gemini-cli npm releases ship their entrypoint at
# `bundle/gemini.js` (package.json `bin.gemini`), so `dist/index.js` no longer
# exists and `gemini` dies with MODULE_NOT_FOUND. Repoint the wrapper.
#
# OAuth token exchange currently fails for some users on affected Node runtimes
# with `Invalid response body ... oauth2.googleapis.com/token: Premature close`.
# Upstream issues report Node 26.3.x as problematic and Node 26.4.0 as a
# working mitigation, so build the wrapper with a pinned Node 26.4.0 until the
# gaxios/TLS-handshake path is fixed upstream.
#
# Apply AFTER gemini-cli-nix.overlays.default. replace-fail makes the build
# fail loudly once upstream fixes the path, signalling this overlay can go.
{ nixpkgs-nodejs-gemini }:
self: super:
let
  geminiNodePkgs = import nixpkgs-nodejs-gemini {
    inherit (super.stdenv.hostPlatform) system;
    config = super.pkgs.config or { };
  };
in
{
  gemini-cli = (super.gemini-cli.override { nodejs_22 = geminiNodePkgs.nodejs_26; }).overrideAttrs (old: {
    postFixup = (old.postFixup or "") + ''
      substituteInPlace $out/bin/gemini \
        --replace-fail "dist/index.js" "bundle/gemini.js"

      substituteInPlace $out/bin/gemini \
        --replace-fail 'exec "' \
          'export GEMINI_CLI_SYSTEM_DEFAULTS_PATH="''${GEMINI_CLI_SYSTEM_DEFAULTS_PATH:-$HOME/.config/gemini-cli/system-defaults.json}"
      export GEMINI_CLI_SYSTEM_SETTINGS_PATH="''${GEMINI_CLI_SYSTEM_SETTINGS_PATH:-$HOME/.config/gemini-cli/settings.json}"
      exec "'
    '';
  });
}
# vim: set ts=2 sw=2 et ai list nu
