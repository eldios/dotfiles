{ pkgs, ... }:
{
  # Neovim configuration deps
  home = {
    packages = with pkgs; [
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

  xdg.configFile."nvim/init.lua".text = ''
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      -- bootstrap lazy.nvim
      -- stylua: ignore
      vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
    end
    vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

    require("lazy").setup({
      spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "lazyvim.plugins.extras.ui.mini-animate" },
        -- Lele LazyVim settings
        { import = "lazyvim.plugins.extras.lang.docker" },
        { import = "lazyvim.plugins.extras.lang.terraform" },
        { import = "lazyvim.plugins.extras.lang.markdown" },
        { import = "lazyvim.plugins.extras.lang.yaml" },
        { import = "lazyvim.plugins.extras.lang.typescript" },
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.lang.go" },
        { import = "lazyvim.plugins.extras.lang.rust" },
        { import = "lazyvim.plugins.extras.lang.python" },
        { import = "lazyvim.plugins.extras.coding.codeium" },
        -- override via plugins
        { import = "plugins" },
      },
      defaults = {
        lazy = false,
        -- version = false, -- always use the latest git commit
        version = "*", -- try installing the latest stable version for plugins that support semver
      },
      install = { colorscheme = { "tokyonight", "habamax" } },
      checker = { enabled = true },
      performance = {
        rtp = {
          -- disable some rtp plugins
          disabled_plugins = {
            "gzip",
            -- "matchit",
            -- "matchparen",
            -- "netrwPlugin",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
  '';

  programs = {

    neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withNodeJs = true;
      withRuby = true;
      withPython3 = true;

      extraPackages = with pkgs; [
        codeium
      ];

      plugins = with pkgs.vimPlugins; [
      ];

      extraConfig = ''
      '';

      extraLuaConfig = ''
      '';
    }; # EOM neovim

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
