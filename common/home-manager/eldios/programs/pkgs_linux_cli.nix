{ pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
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
      p7zip
      powertop
      sshx
      tty-share
      yt-dlp
    ] ++ (with unstablePkgs; [ ]);
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
