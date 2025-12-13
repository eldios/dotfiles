# Desktop/laptop host - use full GUI programs
# Note: Previously had duplicate kitty.nix import (now fixed)
{
  imports = [
    ../../../common/home-manager/eldios/common_programs_gui.nix

    # AI tools
    ../../../common/home-manager/eldios/programs/packages_claude_code.nix
    ../../../common/home-manager/eldios/programs/packages_gemini_cli.nix
  ];
}

# vim: set ts=2 sw=2 et ai list nu
