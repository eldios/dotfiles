# Flake outputs that are not host or home configurations.
{
  inputs,
  lib,
  ...
}: let
  forAllSystems = lib.genAttrs [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-linux"
  ];
in {
  flake.formatter = forAllSystems (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);

  # Tools for working on this repo (scripts/, Justfile): `nix develop`.
  flake.devShells = forAllSystems (
    system: let
      p = inputs.nixpkgs.legacyPackages.${system};
    in {
      default = p.mkShell {
        packages = with p; [
          alejandra
          curl
          jq
          just
          nodejs
          prefetch-npm-deps
          python3
          shellcheck
        ];
      };
    }
  );
}
