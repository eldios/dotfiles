# Packages for common graphical user interface tools and fonts, intended to be cross-platform.
# NOTE: alacritty is installed via programs.alacritty.enable in alacritty.nix
{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      [
        # Screenshots
        (flameshot.override { enableWlrSupport = true; }) # screenshot tool with Wayland support

        # Terminal Themes
        alacritty-theme # theme collection for Alacritty

        # Media & Video
        ffmpeg # multimedia processing toolkit
        imagemagick # image manipulation toolkit
        jellyfin-media-player # Jellyfin media client
        yewtube # YouTube player for terminal
        yt-dlp # video downloader from websites

        # Desktop Utilities
        papirus-icon-theme # icon theme for Linux desktop
        wmctrl # X11 window manager control tool

        # Fonts
        anonymousPro # monospace font for coding
        corefonts # Microsoft core fonts
        font-awesome # icon font
        meslo-lgs-nf # Meslo Nerd Font for terminal
      ]
      ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts));
  }; # EOF
}
# vim: set ts=2 sw=2 et ai list nu
