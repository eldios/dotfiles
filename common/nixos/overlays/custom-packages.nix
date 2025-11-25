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

  claude-code = super.stdenv.mkDerivation rec {
    pname = "claude-code";
    version = "2.0.53";

    src = super.fetchurl {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
      sha256 = "1ipimfj418fm2hvg4wgl3940mpfhbq6mi8a0l5zbzdkz42gc2k4w";
    };

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      cp $src $out/bin/claude
      chmod +x $out/bin/claude
      runHook postInstall
    '';

    meta = with super.lib; {
      description = "Claude Code - AI-powered coding assistant for your terminal";
      homepage = "https://github.com/anthropics/claude-code";
      license = licenses.unfree;
      platforms = platforms.linux;
      mainProgram = "claude";
    };
  };
in
{
  gemini-cli = super.gemini-cli.overrideAttrs geminiCliOverride;

  inherit claude-code;
  unstable = super.unstable // {
    gemini-cli = super.unstable.gemini-cli.overrideAttrs geminiCliOverride;
    inherit claude-code;
  };
}
