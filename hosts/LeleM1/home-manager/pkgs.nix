{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      colorls # like `ls --color=auto -F` but cooler
      ffmpeg
      imagemagick
      neofetch
      yt-dlp
      rclone
      sshfs
      gnupg
      sipcalc
      util-linux

      # fonts
      anonymousPro
      corefonts
      fira-code-nerdfont
      font-awesome
      meslo-lgs-nf
      nerdfonts
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
