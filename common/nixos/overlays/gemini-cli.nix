# Overlay for Gemini CLI version override
#
# === GEMINI-CLI UPDATE ===
# Get latest version:
#   curl -s https://api.github.com/repos/google-gemini/gemini-cli/releases/latest | jq -r .tag_name
#
# Get src hash:
#   nix-prefetch-github google-gemini gemini-cli --rev vVERSION
#
# Get npm hash (clone + prefetch):
#   V=0.27.0 && cd /tmp && rm -rf gemini-cli && git clone --depth=1 -b v$V https://github.com/google-gemini/gemini-cli && cd gemini-cli && nix-shell -p prefetch-npm-deps --run "prefetch-npm-deps package-lock.json"
#
self: super:
let
  geminiCliOverride = oldAttrs: rec {
    version = "0.28.2";

    src = super.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = "v${version}";
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-IOc4Y8U2J4Dpl0A5gfffAayiHKISlFiHU2qg61fR1Tw=";
    };

    npmDeps = super.fetchNpmDeps {
      inherit src;
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-XfD+PmmeLsbb9rC7DCmqu08/+cXZpGewMN5olrHhH4M=";
    };

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
      super.pkg-config
      super.removeReferencesTo
    ];

    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
      super.libsecret
    ];

    preConfigure = ''
      mkdir -p packages/generated
      echo "export const GIT_COMMIT_INFO = { commitHash: '${src.rev}' };" > packages/generated/git-commit.ts
    '';

    # Strip references to build-time only dependencies
    postInstall = (oldAttrs.postInstall or "") + ''
      find $out -type f -exec remove-references-to -t ${npmDeps} {} + 2>/dev/null || true
    '';

    # python3 reference comes from node-gyp build but isn't a real runtime dep
    disallowedReferences = [ ];

    # Override postPatch to fix the substitution for v0.26.0+
    # Upstream changed from disableAutoUpdate to enableAutoUpdate
    # Two substitutions to avoid matching enableAutoUpdateNotification:
    # 1. enableAutoUpdate followed by comma (function argument)
    # 2. enableAutoUpdate at end of line (condition expression)
    postPatch = ''
      sed -i 's/settings\.merged\.general\.enableAutoUpdate,/false,/g' \
        packages/cli/src/utils/handleAutoUpdate.ts
      sed -i 's/settings\.merged\.general\.enableAutoUpdate$/false/' \
        packages/cli/src/utils/handleAutoUpdate.ts
    '';
  };
in
{
  gemini-cli = super.gemini-cli.overrideAttrs geminiCliOverride;

  unstable = (super.unstable or { }) // {
    gemini-cli = super.unstable.gemini-cli.overrideAttrs geminiCliOverride;
  };
}
# vim: set ts=2 sw=2 et ai list nu
