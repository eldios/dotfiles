# QBZ v2 replaced the v1 Tauri app with a Rust/Slint `crates/` workspace,
# so nixpkgs' qbz (still 1.2.x) cannot be overridden — this overlay rebuilds
# the package from the upstream tag, ported from the flake.nix in
# github.com/vicrodh/qbz.
# To bump: set `version`, then refresh `hash` from the hash-mismatch error
# on rebuild. The cargo lockfile is read from the fetched src, so there is
# no vendor hash to refresh.
# Upstream tags: https://github.com/vicrodh/qbz/tags
final: _prev: let
  pkgs = final.unstable;
  version = "2.0.1";
  src = pkgs.fetchFromGitHub {
    owner = "vicrodh";
    repo = "qbz";
    tag = "v${version}";
    hash = "sha256-rUL0yYXn2pCniGIsIdMd0EgAQmHir6I/rr8A/rP7cz4=";
  };
  # winit/wgpu/glutin dlopen these at runtime; a Nix binary cannot find
  # system copies, so the installed program is wrapped with this path.
  # X11 libs included so the app is not Wayland-only.
  runtimeLibs = with pkgs; [
    wayland
    libxkbcommon
    libglvnd
    vulkan-loader
    libx11
    libxcursor
    libxi
  ];
in {
  qbz = pkgs.rustPlatform.buildRustPackage {
    pname = "qbz";
    inherit version src;

    cargoRoot = "crates";
    buildAndTestSubdir = "crates";
    # Build only the app binary, not every workspace member.
    cargoBuildFlags = ["-p" "qbz"];
    cargoLock.lockFile = "${src}/crates/Cargo.lock";

    env.LIBCLANG_PATH = "${pkgs.lib.getLib pkgs.llvmPackages.libclang}/lib";

    nativeBuildInputs = with pkgs; [
      clang
      pkg-config
      cmake
      nasm
      makeWrapper
    ];

    buildInputs = with pkgs; [
      alsa-lib
      fontconfig
      freetype
      libjack2
    ];

    # The qbz_ui rustc alone peaks ~30 GB; running the test profile on top
    # doubles wall time and memory for no packaging value. Engine crates
    # are tested in the repo's CI.
    doCheck = false;

    postInstall = ''
      wrapProgram $out/bin/qbz \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs}

      install -Dm644 $src/packaging/linux/qbz.desktop \
        $out/share/applications/qbz.desktop
      for size in 32 48 64 128 256 512; do
        install -Dm644 $src/packaging/icons/"$size"x"$size".png \
          $out/share/icons/hicolor/"$size"x"$size"/apps/qbz.png
      done
    '';

    meta = with pkgs.lib; {
      description = "Native, full-featured hi-fi Qobuz desktop player for Linux";
      homepage = "https://qbz.lol";
      license = licenses.mit;
      mainProgram = "qbz";
      platforms = platforms.linux;
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
