# GitButler GUI + `but` CLI, both built from the same upstream release tag
# (nixpkgs' gitbutler ships only the Tauri GUI and omits `but`).
# To bump: set `version`, refresh `src.hash`, then rebuild — hash-mismatch
# errors print the correct `cargoDeps`/`pnpmDeps` hashes.
# Upstream tags: https://github.com/gitbutlerapp/gitbutler/tags
final: _prev: let
  version = "0.21.0";
  src = final.unstable.fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${version}";
    hash = "sha256-V7lLzVADjaQMwQ8VeAlWTj5iNXRI0GNy/8Ec/q3NDUs=";
  };
  rp = final.unstable.rustPlatform;
  # GUI and CLI share the workspace Cargo.lock, so one vendor tree serves both.
  cargoDeps = rp.fetchCargoVendor {
    inherit src;
    name = "gitbutler-${version}-vendor";
    hash = "sha256-XZUpK9vTlZyYcfrifru0tfM/zODzLOMAridd7ImAEc8=";
  };
in {
  gitbutler = final.unstable.gitbutler.overrideAttrs (_finalAttrs: prev: {
    inherit version src cargoDeps;

    # The `but` integration tests build git fixtures by running scripts at
    # check time; the Nix sandbox has no git for that. Those tests belong to
    # the CLI crate anyway (gitbutler-cli, also unchecked).
    doCheck = false;
    # prev.pnpmDeps already tracks the new src/version via finalAttrs;
    # only its fixed-output hash needs refreshing.
    pnpmDeps = prev.pnpmDeps.overrideAttrs {
      outputHash = "sha256-ZgRJWPCf6L1AHus16+AZ+apNFYf3ib6KnimyGopQjUs=";
    };

    # nixpkgs' 0.19.9 postPatch lists `gitbutler-git-setsid` in externalBin, but
    # upstream dropped that binary; Linux release builds ship askpass only and
    # enable `builtin-but` (scripts/release.sh in the gitbutler repo).
    postPatch = ''
      tauriConfRelease="crates/gitbutler-tauri/tauri.conf.release.json"
      jq '.
          | (.version = "${version}")
          | (.bundle.createUpdaterArtifacts = false)
          | (.bundle.externalBin = ["gitbutler-git-askpass"])
        ' "$tauriConfRelease" | sponge "$tauriConfRelease"

      substituteInPlace apps/desktop/src/lib/backend/tauri.ts \
        --replace-fail 'checkUpdate = tauriCheck;' 'checkUpdate = () => null;'
    '';

    tauriBuildFlags = prev.tauriBuildFlags ++ [
      "--features"
      "builtin-but,packaged-but-distribution"
    ];
  });

  gitbutler-cli = rp.buildRustPackage {
    pname = "gitbutler-cli";
    inherit version src cargoDeps;

    nativeBuildInputs = [
      final.unstable.pkg-config
      final.unstable.cmake
    ];
    buildInputs = [
      final.unstable.libgit2
      final.unstable.openssl
      final.unstable.dbus # libdbus-sys build dep
    ];

    env = {
      RUSTFLAGS = "--cfg tokio_unstable";
      OPENSSL_NO_VENDOR = true;
      LIBGIT2_NO_VENDOR = 1;
    };

    # Build only the CLI crate; `packaged-but-distribution` disables self-update
    # (updates are managed by Nix). `legacy` stays on via default features.
    cargoBuildFlags = [ "-p" "but" "--features" "packaged-but-distribution" ];
    doCheck = false;

    meta = {
      description = "GitButler CLI (but)";
      homepage = "https://github.com/gitbutlerapp/gitbutler";
      license = final.lib.licenses.fsl11Mit;
      mainProgram = "but";
      platforms = final.lib.platforms.linux;
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
