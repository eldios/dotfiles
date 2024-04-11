{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      guvcview
      obs-studio
      quickemu
      quickgui
      spice
      remmina
      uvcdynctrl
      vlc
    ];
  };
} # EOF
