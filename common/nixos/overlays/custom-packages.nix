# Overlay for custom package versions not available in nixpkgs
#
# === CLAUDE-CODE UPDATE STEPS ===
# 1. Check latest: curl -fsSL https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/stable
# 2. Get src hash: nix-prefetch-url --unpack "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-VERSION.tgz"
# 3. Convert hash: nix hash convert --hash-algo sha256 --to sri HASH_FROM_STEP_2
# 4. Update version + hash below, npmDepsHash rarely changes (only if sharp deps change)
#
# === GEMINI-CLI UPDATE STEPS ===
# 1. Check latest: curl -s https://api.github.com/repos/google-gemini/gemini-cli/releases/latest | jq -r .tag_name
# 2. Get src hash: nix-prefetch-github google-gemini gemini-cli --rev vVERSION
# 3. Get npm hash: cd /tmp && git clone --depth=1 -b vVERSION https://github.com/google-gemini/gemini-cli && cd gemini-cli && nix-shell -p prefetch-npm-deps --run "prefetch-npm-deps package-lock.json"
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

    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [
      super.pkg-config
    ];

    buildInputs = (oldAttrs.buildInputs or []) ++ [
      super.libsecret
    ];

    preConfigure = ''
      mkdir -p packages/generated
      echo "export const GIT_COMMIT_INFO = { commitHash: '${src.rev}' };" > packages/generated/git-commit.ts
    '';
  };

  claudeCodeOverride = oldAttrs: rec {
    version = "2.0.56";

    src = super.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-HuT2y0pyVc9wFrWBLffqCrrpN60YN1cl5NPwzOK0q98=";
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
