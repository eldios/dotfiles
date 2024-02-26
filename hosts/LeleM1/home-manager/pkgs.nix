{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      colorls # like `ls --color=auto -F` but cooler
      ffmpeg
      gnupg
      imagemagick
      rclone
      ripgrep-all
      sipcalc
      sshfs
      util-linux
      yt-dlp
      yazi

      # deps
      libiconv

      # DevOps stuff
      docker
      terraform

      # Kubernetes stuff
      k8sgpt
      k9s
      kdash
      kind
      ktop
      kubectl
      kubectx

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
