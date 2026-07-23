{
  inputs,
  config,
  pkgs,
  ...
}:
let
  secretspath = builtins.toString inputs.secrets;
  cacheUrl = "https://nix-cache.casa.lele.rip";

  # Upload locally-built paths to the local ncps cache.
  # Must never exit non-zero: Nix aborts the build when the hook fails.
  # Short connect-timeout keeps offline builds fast.
  ncpsUploadHook = pkgs.writeShellScript "ncps-upload" ''
    set -uf
    export IFS=' '
    # Sign the whole closure first: fetched paths (flake input sources) are
    # added to the store unsigned, and ncps rejects unsigned narinfos.
    ${config.nix.package}/bin/nix \
      --extra-experimental-features nix-command \
      store sign --key-file ${config.sops.secrets."nix/cache-push-key".path} \
      --recursive $OUT_PATHS || true
    ${config.nix.package}/bin/nix \
      --extra-experimental-features nix-command \
      copy --option connect-timeout 2 \
      --to '${cacheUrl}/upload' $OUT_PATHS || true
  '';
in
{
  # Per-host key used to sign locally-built paths (secret-key-files);
  # ncps only accepts uploads signed by one of these keys.
  sops.secrets."nix/cache-push-key" = {
    sopsFile = "${secretspath}/${config.networking.hostName}.yaml";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Try local cache first, then fallback to upstream
    substituters = [
      "${cacheUrl}" # Local NCPS cache
      "https://cache.nixos.org" # Upstream fallback
      "https://nix-community.cachix.org"
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
    ];

    # Trust the NCPS signing key
    # Get key with: curl https://nix-cache.casa.lele.rip/pubkey
    trusted-public-keys = [
      "nix-cache.casa.lele.rip:MIX0pJiXpRwrpCmg4sV804gXPkohMs2+EroVLSOqHKg="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      # Per-host push keys (paths built and uploaded by sibling hosts)
      "lele8845ace-nix-push-1:Tqs2nfkjeSpDMOOHCDtzjDtpuOD4cWi05k7/lGkXU7E="
      "lele9iyoga-nix-push-1:h2Ip1j6X79KIGnX5vlxU9nlN684SZ+QI7SXyw/2f48c="
      "mininixos-nix-push-1:wAFw+Wz/l+1bm+3v1pDHK2mQUQzmj12EkBszRfa6y28="
      "sox1x-nix-push-1:0RxMtKvsAVI3MOIDXnHG8g6iFYoS5idNRvzB0KMw9ao="
    ];

    # Sign every locally-built path with this host's push key
    secret-key-files = [ config.sops.secrets."nix/cache-push-key".path ];

    # Share locally-built paths with the other hosts via ncps
    post-build-hook = ncpsUploadHook;

    # Fast fallback when local cache is unreachable (outside home network)
    connect-timeout = 1;
    fallback = true;
  };
}

# vim: set ts=2 sw=2 et ai list nu
