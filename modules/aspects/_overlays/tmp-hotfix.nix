# Temporary fixes for packages broken in the pinned nixpkgs inputs. Each
# entry names the upstream fix it waits for; drop the entry once that fix is
# in the input the package comes from. Nothing here is meant to outlive a
# flake update or two.
#
# Desktop packages come from the `unstable` namespace (see
# unstable-packages.nix), so a fix for one of them goes inside that set.
_final: prev: {
  unstable =
    prev.unstable
    // {
    };

  # glances before 4.5.9 depends on python-jose, which nixpkgs refuses to
  # evaluate (CVE-2026-120459). 4.5.9 moved to PyJWT and is on release-26.05
  # (NixOS/nixpkgs 05307bdee7); drop once nixos-26.05 carries it.
  glances =
    if prev.lib.versionOlder prev.glances.version "4.5.9"
    then
      prev.glances.overridePythonAttrs (old: {
        version = "4.5.9";
        src = old.src.override {
          tag = "v4.5.9";
          hash = "sha256-CvT9GQ29xXTVxC7V2nGmfDhHLsAtF61+XMMLG8cmHww=";
        };
        dependencies =
          builtins.filter (dep: (dep.pname or "") != "python-jose") old.dependencies
          ++ [prev.python3Packages.pyjwt];
        nativeCheckInputs = old.nativeCheckInputs ++ [prev.python3Packages.pysmart];
      })
    else prev.glances;
}
# vim: set ts=2 sw=2 et ai list nu

