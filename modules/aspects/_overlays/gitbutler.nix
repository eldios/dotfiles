# GitButler as one package. The Tauri GUI binary is multi-call (`builtin-but`),
# so it also acts as the `but` CLI/TUI when invoked by that name. We add the
# `but` and `gitbutler` symlinks to it - upstream's Linux .deb does the same
# `but -> gitbutler-tauri` symlink; nixpkgs ships only `gitbutler-tauri`.
# To bump: set `version`, then refresh the src/cargoDeps/pnpmDeps hashes from
# the hash-mismatch errors on rebuild.
# Upstream tags: https://github.com/gitbutlerapp/gitbutler/tags
final: _prev: let
  version = "0.22.3";
  src = final.unstable.fetchFromGitHub {
    owner = "gitbutlerapp";
    repo = "gitbutler";
    tag = "release/${version}";
    hash = "sha256-nW3yCbpbIhawLQVV+DptzGYiFBSKcyAP89NtDWHJM+0=";
  };
  cargoDeps = final.unstable.rustPlatform.fetchCargoVendor {
    inherit src;
    name = "gitbutler-${version}-vendor";
    hash = "sha256-XRc2yok9K7f/vRAqgO78JUq/U36XSiUeOINupfOOSjw=";
  };
in {
  gitbutler = final.unstable.gitbutler.overrideAttrs (_finalAttrs: prev: {
    inherit version src cargoDeps;

    # prev.pnpmDeps already tracks the new src/version via finalAttrs;
    # only its fixed-output hash needs refreshing.
    pnpmDeps = prev.pnpmDeps.overrideAttrs {
      outputHash = "sha256-aqz9IbpvG0zOz7cQWpRzEtqLAgI250dN2bBTp1wBhkE=";
    };

    # The `but` integration tests build git fixtures by running scripts at
    # check time; the Nix sandbox has no git for that.
    doCheck = false;

    # 0.22.0 enables git2's unstable_sha256 feature: libgit2-sys then probes
    # for a system libgit2-experimental (GIT_EXPERIMENTAL_SHA256), which
    # nixpkgs does not ship. Build the vendored, sha256-enabled libgit2
    # instead of forcing the system one.
    env = prev.env // {LIBGIT2_NO_VENDOR = 0;};

    # nixpkgs' 0.19.9 postPatch lists `gitbutler-git-setsid` in externalBin, but
    # upstream dropped that binary; Linux release builds ship askpass only and
    # enable `builtin-but` (scripts/release.sh in the gitbutler repo).
    postPatch = ''
      tauriConfRelease="crates/gitbutler-tauri/tauri.conf.release.json"
      jq '.
          | (.version = "${version}")
          | (.bundle.createUpdaterArtifacts = false)
          | (.bundle.externalBin = ["gitbutler-git-askpass"])
        ' "$tauriConfRelease" | sponge "$tauriConfRelease"

      substituteInPlace apps/desktop/src/lib/backend/tauri.ts \
        --replace-fail 'checkUpdate = tauriCheck;' 'checkUpdate = () => null;'
    '';

    # `builtin-but` makes the one binary act as `but` when invoked by that name.
    tauriBuildFlags =
      prev.tauriBuildFlags
      ++ [
        "--features"
        "builtin-but,packaged-but-distribution"
      ];

    # `but` = CLI/TUI (with `but tui` / `but gui` subcommands); `gitbutler` = GUI.
    # Both symlink the one multi-call binary, like upstream's .deb `but` symlink.
    postInstall =
      (prev.postInstall or "")
      + ''
        ln -sf gitbutler-tauri $out/bin/but
        ln -sf gitbutler-tauri $out/bin/gitbutler
      '';
  });
}
# vim: set ts=2 sw=2 et ai list nu

