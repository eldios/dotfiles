{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Try local cache first, then fallback to upstream
    substituters = [
      "https://nix-cache.casa.lele.rip" # Local NCPS cache
      "https://cache.nixos.org" # Upstream fallback
      "https://nix-community.cachix.org"
      "https://walker.cachix.org"
      "https://walker-git.cachix.org"
    ];

    # Trust the NCPS signing key
    # Get key with: curl https://nix-cache.casa.lele.rip/pubkey
    trusted-public-keys = [
      "nix-cache.casa.lele.rip:pXEMvYrY/AgTKBw7A1d4DZi8YRbjBby3eMxnmEo3Aqs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
      "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
    ];

    # Fast fallback when local cache is unreachable (outside home network)
    connect-timeout = 1;
    fallback = true;
  };
}

# vim: set ts=2 sw=2 et ai list nu
