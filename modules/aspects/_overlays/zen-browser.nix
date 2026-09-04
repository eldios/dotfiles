# Overlay: Zen Browser
#
# The upstream flake (github:youwen5/zen-browser-flake) exports packages but no
# overlay. This overlay adds pkgs.zen-browser from the flake's packages output.
{zen-browser, ...}: self: super: {
  zen-browser = zen-browser.packages.${super.stdenv.hostPlatform.system}.default;
}
# vim: set ts=2 sw=2 et ai list nu

