# Overlay for custom package versions not available in nixpkgs
#
# === CLAUDE-CODE UPDATE ===
# Get latest version (npm is authoritative, stable channel lags):
#   curl -s https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r .version
#
# Get hash + convert to SRI (one-liner):
#   V=2.0.67 && nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url --unpack "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-$V.tgz" 2>/dev/null)
#
# === GEMINI-CLI UPDATE ===
# Get latest version:
#   curl -s https://api.github.com/repos/google-gemini/gemini-cli/releases/latest | jq -r .tag_name
#
# Get src hash:
#   nix-prefetch-github google-gemini gemini-cli --rev vVERSION
#
# Get npm hash (clone + prefetch):
#   V=0.17.1 && cd /tmp && rm -rf gemini-cli && git clone --depth=1 -b v$V https://github.com/google-gemini/gemini-cli && cd gemini-cli && nix-shell -p prefetch-npm-deps --run "prefetch-npm-deps package-lock.json"
#
self: super:
let
  geminiCliOverride = oldAttrs: rec {
    version = "0.25.2";

    src = super.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = "v${version}";
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-2Fl6bkoAgu+KvwVIkQEIAPYKQRYyEQPWMRv3vsfnNA4=";
    };

    npmDeps = super.fetchNpmDeps {
      inherit src;
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-4peAAxCws5IjWaiNwkRBiaL+n1fE+zsK0qbk1owueeY=";
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
  };

  claudeCodeOverride = oldAttrs: rec {
    version = "2.1.19";

    src = super.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-K2fJf1eRAyqmtAvKBzpAtMohQ4B1icwC9yf5zEf52C8=";
    };
  };
in
{
  gemini-cli = super.gemini-cli.overrideAttrs geminiCliOverride;
  claude-code = super.claude-code.overrideAttrs claudeCodeOverride;

  unstable = super.unstable // {
    gemini-cli = super.unstable.gemini-cli.overrideAttrs geminiCliOverride;
    claude-code = super.unstable.claude-code.overrideAttrs claudeCodeOverride;
  };
}
