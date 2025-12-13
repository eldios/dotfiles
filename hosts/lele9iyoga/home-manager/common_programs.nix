# Desktop/laptop host - use full GUI programs
# Note: Previously had duplicate kitty.nix import (now fixed)
{
  imports = [
    ../../../common/home-manager/eldios/common_programs_gui.nix
  ];
}

# vim: set ts=2 sw=2 et ai list nu
