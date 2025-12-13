{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    gemini-cli
  ];
}

# vim: set ts=2 sw=2 et ai list nu
