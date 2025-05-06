{ pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };

  neovim-unwrapped = unstablePkgs.neovim-unwrapped.overrideAttrs (old: {
    meta = old.meta or { } // {
      maintainers = [ ];
    };
  });
in
{
  environment.variables.EDITOR = "${pkgs.neovim}/bin/nvim";

  programs = {

    neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      package = neovim-unwrapped;

      configure = {
        customRC = ''
          set modeline
          colorscheme gruvbox
          set nu list sw=2 ts=2 expandtab
        '';
        package.myVimPackage = with pkgs.vimPlugins; {
          start = [
            vim-nix
            gruvbox
          ];
        };
      };
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
