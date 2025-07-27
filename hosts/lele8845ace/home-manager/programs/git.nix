{ config, ... }:
{
  # Nix configuration for user-level commands
  nix = {
    extraOptions = ''
      !include ${config.sops.secrets."tokens/github/nix".path}
    '';

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  programs = {

    git = {
      extraConfig = {
        user = {
          signinkey = "64F87759366D72D60055C0BD3EDE14869955C119";
        };
      };
    }; # EOM git

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
