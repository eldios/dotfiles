{ pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  codeium = unstablePkgs.codeium.overrideAttrs (_finalAttrs: _previousAttrs: {
    version = "1.8.80";
    src = unstablePkgs.fetchurl {
      name = "${_finalAttrs.pname}-${_finalAttrs.version}.gz";
      url = "https://github.com/Exafunction/codeium/releases/download/language-server-v${_finalAttrs.version}/language_server_linux_x64.gz";
      hash = "sha256-ULHO7NrbW0DDlOYiSHGXwJ+NOa68Ma+HMHgq2WyAKBA=";
    };
  });
in
{
  # Neovim configuration deps
  home = {
    packages = with pkgs; [
      # LSPs
      nil # Nix LSP
      deno
      # Golang
      go
      # Rust
      cargo
      rustc
      rustfmt
      # Haskell
      ghc
      # vars
      ripgrep # used by space-f-g
      ripgrep-all # used by space-f-g
    ] ++ (with unstablePkgs; [ ] ++ [
      codeium
    ]);

  };

  # this file is used to setup LazyVim
  xdg.configFile."nvim/init.lua".text = ''
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
          { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
          { out, "WarningMsg" },
          { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
      end
    end
    vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

    require("lazy").setup({
      spec = {
        -- add LazyVim and import its plugins
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- import/override with your plugins
        { import = "plugins" },
      },
      defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
      },
      install = { colorscheme = { "tokyonight", "habamax" } },
      checker = {
        enabled = true, -- check for plugin updates periodically
        notify = false, -- notify on update
      }, -- automatically check for plugin updates
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
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    return {
      -- Lele UI settings
      { import = "lazyvim.plugins.extras.ui.mini-animate" },
      -- Lele Lang settings
      { import = "lazyvim.plugins.extras.lang.cmake" },
      { import = "lazyvim.plugins.extras.lang.docker" },
      { import = "lazyvim.plugins.extras.lang.go" },
      { import = "lazyvim.plugins.extras.lang.java" },
      { import = "lazyvim.plugins.extras.lang.json" },
      { import = "lazyvim.plugins.extras.lang.markdown" },
      { import = "lazyvim.plugins.extras.lang.python" },
      { import = "lazyvim.plugins.extras.lang.ruby" },
      { import = "lazyvim.plugins.extras.lang.rust" },
      { import = "lazyvim.plugins.extras.lang.tailwind" },
      { import = "lazyvim.plugins.extras.lang.terraform" },
      { import = "lazyvim.plugins.extras.lang.typescript" },
      { import = "lazyvim.plugins.extras.lang.yaml" },
      -- Lele plugins
      { import = "lazyvim.plugins.extras.coding.codeium" },
    }
  '';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/options.lua".text = ''
    -- default Lele's options
    vim.opt.relativenumber = false
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = 2
    vim.opt.softtabstop = 2
    vim.opt.expandtab = true
    vim.opt.colorcolumn = { 80 }
  '';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
  '';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/autocmds.lua".text = ''
  '';

  xdg.configFile."nvim/lua/plugins/cmp.lua".text = ''
    return {
      {
        "hrsh7th/nvim-cmp",
        dependencies = { "hrsh7th/cmp-emoji" },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
          table.insert(opts.sources, { name = "emoji" })
          table.insert(opts.sources, { name = "codeium" })
        end,
      },
    }
  '';
  xdg.configFile."nvim/lua/plugins/codeium.lua".text = ''
    return {
      {
        "Exafunction/codeium.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "hrsh7th/nvim-cmp",
        },
        config = function()
          require("codeium").setup({
            enable_chat = "true",
            tools = {
              language_server = "${codeium}/bin/codeium_language_server"
            }
          })
        end
      }
    }
  '';
  xdg.configFile."nvim/lua/plugins/obsidian.lua".text = ''
    return {
      {
        "epwalsh/obsidian.nvim",
        version = "*",  -- recommended, use latest release instead of latest commit
        lazy = true,
        -- ft = "markdown",
        -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
        event = {
          -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
          -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
          -- "BufReadPre path/to/my-vault/**.md",
          -- "BufNewFile path/to/my-vault/**.md",
          "BufReadPre " .. vim.fn.expand "~" .. "/2nd Brain/**.md",
          "BufNewFile " .. vim.fn.expand "~" .. "/2nd Brain/**.md",
        },
        dependencies = {
          -- Required.
          "nvim-lua/plenary.nvim",
        },
        opts = {
          workspaces = {
            {
              name = "2nd Brain",
              path = "~/2nd Brain",
            },
          },
        },
      }
    }
  '';
  xdg.configFile."nvim/lua/plugins/disabled.lua".text = ''
    return {
      -- disable plugins
      -- { "myplugin", enabled = false }
    }
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

      #extraPackages = with pkgs; [
      #];

      plugins = with pkgs.vimPlugins; [
        nvim-cmp
      ];

      extraConfig = ''
      '';

      extraLuaConfig = ''
      '';
    }; # EOM neovim

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
