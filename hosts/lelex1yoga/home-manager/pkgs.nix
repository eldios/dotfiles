{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      obs-studio
      uvcdynctrl
      guvcview
      vlc
    ];
  };
} # EOF
