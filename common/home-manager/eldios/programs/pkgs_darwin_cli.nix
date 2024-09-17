{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      kubectl

      # deps
      libiconv
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
