# Overlay: Buzz Desktop (Nostr-based workspace for human/agent collaboration)
#
# Ported from a local nixpkgs branch (AltNet/nixpkgs, pr-buzz) that carries
# two fixes the public nixpkgs PR lacks:
#   1. A GStreamer plugin path for the FHS environment's GStreamer (needed
#      for AMD hosts' VAAPI decode; the AppImage's bundled plugins do not
#      load against Nixpkgs' OpenSSL once the bundled copy is removed).
#   2. An xdg-open wrapper that clears the AppImage's LD_LIBRARY_PATH before
#      exec'ing the system xdg-open — AppRun otherwise leaks the bundled
#      libraries into every child process, so a browser launched from inside
#      Buzz loads them and exits before opening the URL.
#
# To bump: set `version`, then refresh `hash` with
#   nix store prefetch-file --json <asset-url> | jq -r .hash
# Releases: https://github.com/block/buzz/releases
final: _prev: let
  pname = "buzz-desktop";
  version = "0.5.18";

  src = final.fetchurl {
    url = "https://github.com/block/buzz/releases/download/desktop-v${version}/Buzz_${version}_amd64.AppImage";
    hash = "sha256-0ErOc3u/juQdV3MGG+q7Fx04orrdUSks3Qa8fBhNP3E=";
  };

  contents = final.appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      # Use the FHS environment's OpenSSL for both Buzz and GStreamer. Keeping
      # the older bundled copy makes Nixpkgs' GStreamer plugins fail to load.
      rm $out/usr/lib/lib{crypto,ssl}.so.3

      substituteInPlace $out/usr/bin/buzz-desktop \
        --replace-fail \
          'exec -a "buzz-desktop" "$here/buzz-desktop.bin" "$@"' \
          'unset APPIMAGE; export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib64/gstreamer-1.0; exec -a "buzz-desktop" "$here/buzz-desktop.bin" "$@"'

      rm $out/usr/bin/xdg-open
      printf '#!/usr/bin/env bash\nexec env -u LD_LIBRARY_PATH /usr/bin/xdg-open "$@"\n' \
        > $out/usr/bin/xdg-open
      chmod +x $out/usr/bin/xdg-open
    '';
  };
in {
  buzz-desktop = final.appimageTools.wrapAppImage {
    inherit pname version;
    src = contents;

    extraPkgs = pkgs:
      with pkgs; [
        elfutils.out
        ffmpeg
        git
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-libav
        zstd.out
      ];

    extraInstallCommands = ''
      install -Dm444 ${contents}/usr/share/applications/Buzz.desktop \
        $out/share/applications/buzz-desktop.desktop
      substituteInPlace $out/share/applications/buzz-desktop.desktop \
        --replace-fail "Exec=buzz-desktop" "Exec=buzz-desktop %u" \
        --replace-fail "Categories=" "Categories=Network;Chat;"
      cp -r ${contents}/usr/share/icons $out/share/
    '';

    passthru.src = src;

    meta = {
      description = "Workspace where humans and AI agents build together";
      homepage = "https://buzz.xyz";
      changelog = "https://github.com/block/buzz/releases/tag/desktop-v${version}";
      license = final.lib.licenses.asl20;
      mainProgram = "buzz-desktop";
      platforms = [ "x86_64-linux" ];
      sourceProvenance = [ final.lib.sourceTypes.binaryNativeCode ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
