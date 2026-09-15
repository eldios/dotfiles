# QBZ v2 replaced the v1 Tauri app with a Rust `crates/` workspace, so
# nixpkgs' qbz (still 1.2.x) cannot be overridden; this overlay rebuilds the
# package from the upstream tag, ported from the flake.nix in
# github.com/vicrodh/qbz.
# To bump: set `version`, then refresh `hash` from the hash-mismatch error
# on rebuild. The cargo lockfile is read from the fetched src, so there is
# no vendor hash to refresh. Re-read the upstream flake.nix on every bump:
# 2.1.0 swapped the Slint frontend for Qt/QML and renamed the app crate.
# Upstream tags: https://github.com/vicrodh/qbz/tags
final: _prev: let
  pkgs = final.unstable;
  version = "2.1.1";
  src = pkgs.fetchFromGitHub {
    owner = "vicrodh";
    repo = "qbz";
    tag = "v${version}";
    hash = "sha256-yjTrKABYX2/fv8j32JEtEF9DQxjO6ebEto2xR3GsALg=";
  };
  # Opened by name at run time rather than linked in. Qt's own graphics and
  # plugin closure is handled by wrapQtAppsHook.
  runtimeLibs = with pkgs; [libjack2];
  runtimeBins = with pkgs; [pipewire pulseaudio xdg-utils];

  # cxx-qt's qt-build-utils locates moc/qmltyperegistrar/qmlcachegen only
  # through `qmake -query`, which reports qtbase's prefix. nixpkgs ships each
  # Qt module as its own store path, so the qtdeclarative tools are invisible
  # there and the build dies with "Could not find qmltyperegistrar". Hand
  # qmake a qt.conf pointing at one libexec that holds both toolsets; every
  # other path stays pinned to its real value, since cxx-qt also queries
  # QT_INSTALL_{PREFIX,HEADERS,LIBS,PLUGINS} to drive the C++ compile.
  qtLibexec = pkgs.runCommand "qbz-qt-libexec" {} ''
    mkdir -p $out/libexec
    ln -s ${pkgs.qt6.qtbase}/libexec/* ${pkgs.qt6.qtdeclarative}/libexec/* $out/libexec/
  '';
  qtConf = pkgs.writeText "qbz-qt.conf" ''
    [Paths]
    Prefix = ${pkgs.qt6.qtbase}
    Plugins = lib/qt-6/plugins
    Qml2Imports = lib/qt-6/qml
    Translations = ${pkgs.qt6.qttranslations}/translations
    LibraryExecutables = ${qtLibexec}/libexec
    HostLibraryExecutables = ${qtLibexec}/libexec
  '';
  qmakeForCxxQt = pkgs.writeShellScriptBin "qmake" ''
    exec ${pkgs.qt6.qtbase}/bin/qmake -qtconf ${qtConf} "$@"
  '';
in {
  qbz = pkgs.rustPlatform.buildRustPackage {
    pname = "qbz";
    inherit version src;

    cargoRoot = "crates";
    buildAndTestSubdir = "crates";
    # Build only the app binary, not every workspace member. The crate is
    # `qbz-qt`; the executable it installs is still `qbz`.
    cargoBuildFlags = ["-p" "qbz-qt"];
    cargoLock.lockFile = "${src}/crates/Cargo.lock";

    # qtbase's setup hook exports QMAKE unconditionally, so it would clobber
    # this as an `env` attribute; setup hooks run before preBuild.
    preBuild = ''
      export QMAKE=${qmakeForCxxQt}/bin/qmake
    '';

    # cxx-qt needs qtbase + qtdeclarative with their private headers (the RHI
    # items include <rhi/qrhi.h>). qtwayland provides the Wayland platform
    # plugin, qtsvg the SVG image plugin, and wrapQtAppsHook sets the
    # plugin/QML paths the binary needs at run time.
    nativeBuildInputs = with pkgs; [
      pkg-config
      cmake
      nasm
      qt6.qmake
      qt6.wrapQtAppsHook
    ];

    buildInputs = with pkgs; [
      alsa-lib
      libjack2
      qt6.qtbase
      qt6.qtdeclarative
      qt6.qtsvg
      qt6.qtwayland
    ];

    # Tests need an offscreen QPA plus a D-Bus the sandbox does not have, and
    # the UI rustc alone is RAM-heavy enough without a second profile. Engine
    # crates are tested in the repo's CI.
    doCheck = false;

    postInstall = ''
      qtWrapperArgs+=(--prefix PATH : ${pkgs.lib.makeBinPath runtimeBins})
      qtWrapperArgs+=(--prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath runtimeLibs})

      install -Dm644 $src/packaging/linux/qbz.desktop \
        $out/share/applications/com.blitzfc.qbz.desktop
      install -Dm644 $src/packaging/flatpak/com.blitzfc.qbz.metainfo.xml \
        $out/share/metainfo/com.blitzfc.qbz.metainfo.xml
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

