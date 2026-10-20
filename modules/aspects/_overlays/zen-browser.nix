# Overlay: Zen Browser
#
# The upstream flake (github:youwen5/zen-browser-flake) exports packages but no
# overlay. This overlay builds pkgs.zen-browser from the flake's own package
# files and sources.json.
#
# The input follows this config's nixpkgs on purpose: the package is the
# official binary tarball run through autoPatchelf and wrapGAppsHook, so
# following costs a cheap re-wrap and saves a second nixpkgs checkout, while
# the flake publishes no binary cache that a separate pin would preserve.
{zen-browser, ...}: self: super: let
  system = super.stdenv.hostPlatform.system;
  sources = builtins.fromJSON (builtins.readFile "${zen-browser}/sources.json");
  # Upstream pins a wrong x86_64 hash for 1.23.3b (youwen5/zen-browser-flake#22,
  # fix in #23); the override stops applying at the next version bump.
  hashFixes."1.23.3b".x86_64-linux = "sha256-uyBF0+IWVNQP6EElAJLurf0sH8gx7vtQkiJ3PIvcoUk=";
  hash = hashFixes.${sources.version}.${system} or sources.${system}.hash;
  zen-browser-unwrapped = super.callPackage "${zen-browser}/zen-browser-unwrapped.nix" {
    inherit hash;
    inherit (sources.${system}) url;
    inherit (sources) version firefoxVersion;
  };
in {
  zen-browser = super.callPackage "${zen-browser}/zen-browser.nix" {inherit zen-browser-unwrapped;};
}
# vim: set ts=2 sw=2 et ai list nu

