# Overlay: Ratspeak
#
# The packaging flake (github:eldios/nix-ratspeak) exports an overlay too, but
# it would rebuild against this config's nixpkgs; using the packages output
# keeps the binary built with the flake's own tested nixpkgs-unstable pin.
{nix-ratspeak, ...}: self: super: {
  ratspeak = nix-ratspeak.packages.${super.stdenv.hostPlatform.system}.default;
}
# vim: set ts=2 sw=2 et ai list nu
