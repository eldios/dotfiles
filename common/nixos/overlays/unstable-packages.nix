# Overlay to add unstable packages to stable pkgs
# This allows home-manager to use unstable packages without separate imports
{ nixpkgs-unstable, ... }:

self: super:
let
  unstablePkgs = import nixpkgs-unstable {
    inherit (super.stdenv.hostPlatform) system;
    config = super.pkgs.config or {}; # Inherit config from main pkgs
    # Fixes that belong to the unstable set itself, so every consumer sees them.
    overlays = [ (import ./hyprland-glaze.nix) ];
  };
in
{
  # Add unstable packages as a namespace
  unstable = unstablePkgs;
}

