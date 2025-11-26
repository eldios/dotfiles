# Overlay for custom package versions not available in nixpkgs
# To check for new versions: curl -fsSL https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/stable
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
    version = "2.0.53";

    src = super.fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-GDk3oROfwlreyZ95oWkUc/OAv8pRHhHLDcwmRzXq3Wg=";
    };

    # This hash will need to be updated - let the build fail once to get the correct hash
    npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
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
