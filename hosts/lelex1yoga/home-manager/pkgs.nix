{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      guvcview
      obs-studio
      quickemu
      quickgui
      uvcdynctrl
      vlc
    ];
  };
} # EOF
