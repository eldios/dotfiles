{ pkgs, ... }:
{
  # Neovim configuration deps
  home = {
    packages = with pkgs; [
      gcal
      graph-easy
      iotop
      ncdu
      networkmanager
      powertop
      yubikey-personalization
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
