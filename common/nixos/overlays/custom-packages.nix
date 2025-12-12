# Overlay for custom package versions not available in nixpkgs
#
# === CLAUDE-CODE UPDATE ===
# Get latest version (npm is authoritative, stable channel lags):
#   curl -s https://registry.npmjs.org/@anthropic-ai/claude-code/latest | jq -r .version
#
# Get hash + convert to SRI (one-liner):
#   V=2.0.67 && nix hash convert --hash-algo sha256 --to sri $(nix-prefetch-url --unpack "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-$V.tgz" 2>/dev/null)
#
# npmDepsHash rarely changes - only update if sharp deps change (build will fail with hash mismatch)
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
    version = "0.17.1";

    src = super.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = "v${version}";
      hash = "sha256-pJveHjguNl8J67zu6O867iM/JlXM9VTAokIQYHvxUYs=";
    };

    npmDeps = super.fetchNpmDeps {
      inherit src;
      hash = "sha256-SVjUt8xoBtuZJa0mUfZCf/XXxc8OxDU7FG8ZYPTM3j4=";
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
    version = "2.0.67";

    src = super.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-a1i8N6LZYA3XJx7AqDDOoyO5pf+t9WZ6vBQVZkUbpxM=";
    };

    # npmDepsHash for optional @img/sharp-* deps - only update if sharp version changes
    npmDepsHash = "sha256-V0rjoKdXGRNNKRJqPvVIqCQpqgNCklPTVRExCCxbe8g=";
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
