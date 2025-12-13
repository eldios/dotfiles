{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    claude-code
  ];
}

# vim: set ts=2 sw=2 et ai list nu
