{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      guvcview
      quickemu
      quickgui
      spice
      remmina
      uvcdynctrl
      vlc
    ];
  };
} # EOF
