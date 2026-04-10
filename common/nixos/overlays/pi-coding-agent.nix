# Overlay: pi.dev coding agent (AI-powered CLI)
#
# Installs the pre-built npm package @mariozechner/pi-coding-agent from the
# npm registry. A local package.json + package-lock.json wrapper lives in
# ./pi-coding-agent/ and pins the exact version.
#
# === PI UPDATE ===
# 1. Check latest: npm view @mariozechner/pi-coding-agent version
# 2. Update version in ./pi-coding-agent/package.json
# 3. Regenerate lock: cd common/nixos/overlays/pi-coding-agent && npm install --package-lock-only
# 4. Update npmDepsHash below (build will tell you the new hash)
#
self: super:
{
  pi-coding-agent = super.buildNpmPackage {
    pname = "pi-coding-agent";
    version = "0.66.1";

    src = ../overlays/pi-coding-agent;

    nodejs = super.nodejs_22;

    npmDepsHash = "sha256-kMBCpkGpx5A5OcWnU3nvg7i6/kefZ8t4pG8wUfQGsoY=";

    # The wrapper has no build step — only runtime deps from npm registry
    dontNpmBuild = true;

    # Link the cli binary
    postInstall = ''
      mkdir -p $out/bin
      ln -s $out/lib/node_modules/pi-coding-agent-wrapper/node_modules/.bin/pi $out/bin/pi
    '';

    meta = with super.lib; {
      description = "Pi coding agent - AI-powered coding assistant CLI from pi.dev";
      homepage = "https://pi.dev";
      mainProgram = "pi";
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
