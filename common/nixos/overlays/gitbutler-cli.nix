# GitButler's `but` CLI. nixpkgs' `gitbutler` builds only the Tauri GUI and omits
# `but`, so we build the crate ourselves from the same source — no GUI/Tauri/pnpm
# toolchain needed. Reuses unstable's gitbutler src + Cargo vendor.
# Follows upstream: `version`/`src` track unstable's gitbutler; bump `cargoHash`
# if the vendored deps change (build error prints the correct hash).
final: _prev: let
  gb = final.unstable.gitbutler;
  rp = final.unstable.rustPlatform;
in {
  gitbutler-cli = rp.buildRustPackage {
    pname = "gitbutler-cli";
    inherit (gb) version src;

    cargoHash = "sha256-7dF865YPcVp/g6PUs5QRaU3wZ0UmlAgaPGhHsIjIZPY=";

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
      license = final.lib.licenses.unfree;
      mainProgram = "but";
      platforms = final.lib.platforms.linux;
    };
  };
}
