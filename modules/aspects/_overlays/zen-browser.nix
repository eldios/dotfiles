# Overlay: Zen Browser
#
# The upstream flake (github:youwen5/zen-browser-flake) exports packages but no
# overlay. This overlay adds pkgs.zen-browser from the flake's packages output.
#
# The input follows this config's nixpkgs on purpose: the package is the
# official binary tarball run through autoPatchelf and wrapGAppsHook, so
# following costs a cheap re-wrap and saves a second nixpkgs checkout, while
# the flake publishes no binary cache that a separate pin would preserve.
{zen-browser, ...}: self: super: {
  zen-browser = zen-browser.packages.${super.stdenv.hostPlatform.system}.default;
}
# vim: set ts=2 sw=2 et ai list nu

