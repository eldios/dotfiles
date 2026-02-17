# Packages for macOS-specific command-line interface tools.
{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      kubectl # Kubernetes command-line tool
      libiconv # character encoding conversion library (dep for other packages)
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
