# Overlay to add unstable packages to stable pkgs
# This allows home-manager to use unstable packages without separate imports
{ nixpkgs-unstable, ... }:

self: super:
let
  unstablePkgs = import nixpkgs-unstable {
    system = super.stdenv.hostPlatform.system;
    config = super.config; # Inherit config from main pkgs to avoid setting it separately
  };
in
{
  # Add unstable packages as a namespace
  unstable = unstablePkgs;
}

