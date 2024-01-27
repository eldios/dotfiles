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

      # ZSH deps
      carapace
      gnupg
      sipcalc
      thefuck
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
