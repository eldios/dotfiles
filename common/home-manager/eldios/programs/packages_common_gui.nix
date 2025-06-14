# Packages for common graphical user interface tools and fonts, intended to be cross-platform.
{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # GUI Utilities
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      cointop
      ffmpeg
      (flameshot.override { enableWlrSupport = true; })
      imagemagick
      papirus-icon-theme # Icon theme for rofi
      wmctrl
      yewtube
      yt-dlp

      # Fonts
      anonymousPro
      corefonts
      font-awesome
      meslo-lgs-nf
    ] ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));
  }; # EOF
}
# vim: set ts=2 sw=2 et ai list nu
