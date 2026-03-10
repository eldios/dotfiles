# Overlay: Google Workspace CLI (gws)
#
# The upstream flake (github:googleworkspace/cli) exports packages but no overlay.
# This overlay adds pkgs.gws from the flake's packages output.
{ gws-cli, ... }:

self: super:
{
  gws = gws-cli.packages.${super.stdenv.hostPlatform.system}.default;
}
# vim: set ts=2 sw=2 et ai list nu
