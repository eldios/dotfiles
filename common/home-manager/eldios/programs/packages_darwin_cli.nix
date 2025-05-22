# Packages for macOS-specific command-line interface tools.
{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      kubectl
      libiconv # dep for other stuff
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
