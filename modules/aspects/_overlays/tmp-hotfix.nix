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
      # DaVinci Resolve Studio 21.1: Blackmagic republished the archive
      # without bumping the version, so the fixed-output hash in nixpkgs no
      # longer matches the file served. Fix pending in NixOS/nixpkgs#562336.
      # The package closes over its source in a let, so the file is
      # re-called with the hash of the archive actually served.
      davinci-resolve-studio =
        prev.unstable.callPackage
        (builtins.toFile "davinci-resolve-package.nix"
          (builtins.replaceStrings
            ["sha256-D5RjUukwKMpULrDfMJOPsPWW9FxhQ/IUMh76u5JLytA="]
            ["sha256-P+zu8/OuFcDcIkwV3UMq0qg9U2JEGRkKDP+VLQesZjw="]
            (builtins.readFile (prev.unstable.path + "/pkgs/by-name/da/davinci-resolve/package.nix"))))
        {studioVariant = true;};
    };
}
# vim: set ts=2 sw=2 et ai list nu

