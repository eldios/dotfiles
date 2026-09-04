# Neovim on both sides: the system editor (vi/vim aliases, gruvbox, a
# minimal rc) and the LazyVim setup in the home with its Nix-provided
# language servers, formatters and AI plugins.
{
  den.aspects.neovim = {
    nixos.imports = [./_neovim/nixos.nix];
    homeManager.imports = [./_neovim/hm.nix];
  };
}
