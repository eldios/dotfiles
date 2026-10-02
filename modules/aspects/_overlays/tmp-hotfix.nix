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
}
# vim: set ts=2 sw=2 et ai list nu

