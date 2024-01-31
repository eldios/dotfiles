{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      colorls # like `ls --color=auto -F` but cooler
      dbeaver
      ffmpeg
      imagemagick
      neofetch
      yt-dlp
      rclone
      sshfs
      gnupg
      sipcalc

      warp-terminal
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
