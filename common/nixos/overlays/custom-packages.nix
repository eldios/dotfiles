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
    version = "0.24.5";

    src = super.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = "v${version}";
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-lv3qqFSDz49CbeYftQJSo4D/hYyJyktoSrU0xF2aPtw=";
    };

    npmDeps = super.fetchNpmDeps {
      inherit src;
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-cjKJyOlrb0J6LuXSPas3w/mf+2kPoOCd566lkK95B2c=";
    };

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
      super.pkg-config
    ];

    buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
      super.libsecret
    ];

    preConfigure = ''
      mkdir -p packages/generated
      echo "export const GIT_COMMIT_INFO = { commitHash: '${src.rev}' };" > packages/generated/git-commit.ts
    '';
  };

  claudeCodeOverride = oldAttrs: rec {
    version = "2.1.12";

    src = super.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      # uncomment the below to force a pkg refresh and get the new hash
      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      hash = "sha256-JX72YEM2fXY7qKVkuk+UFeef0OhBffljpFBjIECHMXw=";
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
