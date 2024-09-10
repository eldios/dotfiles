{ pkgs, ... }:
{
  # Neovim configuration deps
  home = {
    packages = with pkgs; [
      atop
      cloudflare-warp
      gcal
      graph-easy
      imagemagick
      iotop
      k3s
      ncdu
      networkmanager
      ntfs3g
      powertop
      yt-dlp
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
