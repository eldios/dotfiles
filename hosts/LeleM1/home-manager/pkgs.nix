{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # deps
      libiconv
      virt-manager
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
