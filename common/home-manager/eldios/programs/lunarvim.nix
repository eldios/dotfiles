{ pkgs, ... }:
{
  # use LunarVim as a base
  home = {
    # Lunarvim: workaround to have Mason work as intended
    # Add support for ./local/bin
    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages = with pkgs; [
      # the base editor
      lunarvim

      # Language Servers
      rnix-lsp
      haskell-language-server
      rust-analyzer

      # Plugins
      codeium # Codeium.com
      #vimPlugins.codeium-vim # Codeium.com
      vimPlugins.nvim-treesitter.withAllGrammars # TreeSitter grammars

      # development deps
      # Golang
      go
      # Rust
      cargo
      rustc
      rustfmt
      # Haskell
      ghc
      # vars
      ripgrep     # used by space-f-g
    ];
  };

  xdg.configFile."lvim/config.lua" = {
    enable = true;
    text = ''
      -- vim options
      vim.opt.nu                                          = true
      vim.opt.relativenumber                              = false
      vim.opt.list                                        = true

      vim.opt.colorcolumn                                 = "80"

      vim.opt.numberwidth                                 = 4
      vim.opt.textwidth                                   = 78
      vim.opt.shiftwidth                                  = 2
      vim.opt.tabstop                                     = 2
      vim.opt.expandtab                                   = true

      -- general
      lvim.log.level                                      = "info"
      lvim.use_icons                                      = true

      -- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
      lvim.leader                                         = "space"
      -- add your own keymapping
      lvim.keys.normal_mode["<C-s>"]                      = ":w<cr>"
      lvim.keys.normal_mode["<C-S-n>"]                    = ':exec "set rnu!"<cr>'

      lvim.keys.normal_mode["<C-S-l>"]                    = ":BufferLineCycleNext<CR>"
      lvim.keys.normal_mode["<C-S-h>"]                    = ":BufferLineCyclePrev<CR>"

      -- -- Use which-key to add extra bindings with the leader-key prefix
      -- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
      -- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

      -- -- Change theme settings
      -- lvim.colorscheme = "lunar"

      lvim.builtin.alpha.active                           = true
      lvim.builtin.alpha.mode                             = "dashboard"
      lvim.builtin.terminal.active                        = true
      lvim.builtin.nvimtree.setup.view.side               = "left"
      lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

      -- --- disable automatic installation of TreeSitter
      lvim.builtin.treesitter.auto_install                = false

      -- --- disable automatic installation of servers
      lvim.lsp.installer.setup.automatic_installation     = false
    '';
  }; # EOF .lvim/config.lua

} # EOF
# vim: set ts=2 sw=2 et ai list nu
