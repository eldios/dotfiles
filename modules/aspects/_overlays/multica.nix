# Overlay: Multica (agent board and runtime daemon) and the Pi coding agent
#
# The upstream flake (github:numtide/llm-agents.nix) packages the multica CLI,
# the desktop app and pi, but no overlay. The CLI is pinned here to the
# release the self-hosted server runs, ahead of the flake's version, because
# the daemon and the server share one protocol.
#
# Bumped by scripts/update-versions.sh multica, which reads the release from
# the server itself; the nightly prebuild runs it.
# Releases: https://github.com/multica-ai/multica/releases
{llm-agents-nix, ...}: final: _prev: let
  upstream = llm-agents-nix.packages.${final.stdenv.hostPlatform.system};
in {
  multica = upstream.multica.overrideAttrs (old: {
    version = "0.7.0";
    src = final.fetchFromGitHub {
      owner = "multica-ai";
      repo = "multica";
      tag = "v0.7.0";
      hash = "sha256-iUQIMvhTW53zD2oHvBgZRru1jCKutefXzLeDgQCsdWI=";
    };
    vendorHash = "sha256-KJIrY4kLAQ5CBu/ClcXjLHG0FWvSX1ne06OG+ZkL75E=";
    # go.mod asks for Go 1.26.9, newer than any Nixpkgs toolchain so far; a
    # patch release changes no language or API. Drop once Nixpkgs has it.
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace go.mod --replace-fail "go 1.26.9" "go 1.26.8"
      '';
  });
  # Built from the multica release above, so its pnpm dependencies follow it.
  multica-desktop = (upstream.multica-desktop.override {inherit (final) multica;}).overrideAttrs (old: {
    pnpmDeps = old.pnpmDeps.overrideAttrs {
      outputHash = "sha256-gxcisoTxXQGt7aMmJwdag2OYIFMhbW0gTKWzoLsbNvM=";
    };
  });
  pi = upstream.pi;
}
# vim: set ts=2 sw=2 et ai list nu

