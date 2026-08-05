# Hyprland 0.56.1 asks CMake for `glaze 7...<8` while nixpkgs now ships glaze 8,
# so find_package fails, CMake falls back to FetchContent, and the sandboxed
# build dies trying to git clone glaze. This is the same substitution nixpkgs
# applied in e0832b878323 ("hyprland: fix build by relaxing glaze dependency");
# that commit is on master but has not reached the nixos-unstable channel yet.
# Drop this file once the channel advances past it. Upstream removed the bound
# entirely, so newer Hyprland releases will not need it.
#
# Applied inside the unstable package set rather than to a single attribute, so
# anything else built against it picks up the same fix.
_final: prev: {
  hyprland = prev.hyprland.overrideAttrs (old: {
    postPatch =
      ''
        substituteInPlace CMakeLists.txt start/CMakeLists.txt hyprpm/CMakeLists.txt \
          --replace-fail "glaze 7...<8" "glaze"
      ''
      + (old.postPatch or "");
  });
}
