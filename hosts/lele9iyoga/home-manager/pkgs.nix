{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      davinci-resolve-studio
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
