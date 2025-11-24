# Overlay for custom package versions not available in nixpkgs
self: super:
let
  geminiCliOverride = oldAttrs: rec {
    version = "0.17.0";

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
in
{
  gemini-cli = super.gemini-cli.overrideAttrs geminiCliOverride;

  unstable = super.unstable // {
    gemini-cli = super.unstable.gemini-cli.overrideAttrs geminiCliOverride;
  };
}
