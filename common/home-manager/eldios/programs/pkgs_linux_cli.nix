{ pkgs, ... }:
{
  # Neovim configuration deps
  home = {
    packages = with pkgs; [
      cloudflare-warp
      gcal
      graph-easy
      iotop
      k3s
      ncdu
      networkmanager
      ntfs3g
      powertop
      yubikey-personalization
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
