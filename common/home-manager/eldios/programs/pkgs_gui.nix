{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # var
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      cointop
      ffmpeg
      flameshot
      imagemagick
      wmctrl
      yt-dlp

      # fonts
      anonymousPro
      corefonts
      fira-code-nerdfont
      font-awesome
      meslo-lgs-nf
      nerdfonts
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
