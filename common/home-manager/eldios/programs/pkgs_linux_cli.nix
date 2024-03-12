{ pkgs, ... }:
{
  # Neovim configuration deps
  home = {
    packages = with pkgs; [
      cloudflare-warp
      gcal
      graph-easy
      iotop
      ncdu
      networkmanager
      powertop
      yubikey-personalization
      k3s
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
