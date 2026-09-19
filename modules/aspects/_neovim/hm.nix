{
  pkgs,
  config,
  inputs,
  ...
}: let
  neovim-unwrapped = pkgs.unstable.neovim-unwrapped.overrideAttrs (old: {
    meta =
      old.meta or {}
      // {
        maintainers = [];
      };
  });
in {
  home = {
    packages = with pkgs; [
      # LLM related stuff
      aider-chat
      inputs.mpc-hub.packages."${pkgs.stdenv.hostPlatform.system}".default
      # LSPs
      deno
      fd
      lua-language-server
      nil # Nix LSP
      nodejs
      typescript
      # LSPs formerly from Mason, now Nix-native (see plugins/no-mason.lua)
      rust-analyzer
      gopls
      delve
      golangci-lint
      basedpyright
      ruff
      vtsls
      yaml-language-server
      terraform-ls
      tflint
      tfsec
      marksman
      tailwindcss-language-server
      cmake-language-server
      clang-tools
      docker-compose-language-service
      dockerfile-language-server
      vscode-langservers-extracted # json/html/css/eslint
      jdt-language-server
      ruby-lsp
      # formatters + linters (Mason to Nix)
      prettierd
      stylua
      shfmt
      yamlfmt
      yamllint
      actionlint
      nixfmt
      trivy
      tree-sitter
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
    ];
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
          disabled_plugins = {},
        },
      },
    })
  '';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/lazy.lua".text = ''
    return {
      -- UI extras
      { import = "lazyvim.plugins.extras.ui.mini-animate" },

      -- Language support
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

      -- Tool integrations
      { import = "lazyvim.plugins.extras.formatting.prettier" },
      { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
      { import = "lazyvim.plugins.extras.editor.mini-files" },
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
    vim.opt.laststatus = 3
  '';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/keymaps.lua".text = '''';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/autocmds.lua".text = '''';
  # MCPHub servers configuration is now managed by mcp-servers.nix
  # which generates ~/.config/mcphub/servers.json with MCP URLs
  # pointing to the shared docker-compose MCP servers

  # Blink.cmp configuration for manual-only completion
  xdg.configFile."nvim/lua/plugins/blink-cmp.lua".text = ''
    return {
      "saghen/blink.cmp",
      lazy = false, -- ensure it loads early
      -- version = "v0.*", -- use the latest stable version
      dependencies = {
        "rafamadriz/friendly-snippets",
      },
      opts = {
        -- Disable cmdline completion entirely to prevent slash command interference
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = false
            },
            ghost_text = {
              enabled = true
            },
          },
        },

        -- Configure trigger settings to be less aggressive
        trigger = {
          completion = {
            -- Disable completion on trigger characters like "/"
            show_on_insert_on_trigger_character = false,
          },
        },

        signature = { enabled = true },

        completion = {
          menu = {
            auto_show = false,
            enabled = true,
          },
        },

      },
    }
  '';

  # MPC-HUB - https://ravitemer.github.io/mcphub.nvim/installation.html#lazy-nvim
  xdg.configFile."nvim/lua/plugins/mpc-hub.lua".text = ''
    return {
      "ravitemer/mcphub.nvim",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      config = function()
        require("mcphub").setup({
            --- `mcp-hub` binary related options-------------------
            config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to MCP Servers config file (will create if not exists)
            port = 37373, -- The port `mcp-hub` server listens to
            shutdown_delay = 60 * 10 * 1000, -- Delay in ms before shutting down the server when last instance closes (default: 10 minutes)
            use_bundled_binary = false, -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua")
            mcp_request_timeout = 60000, --Max time allowed for a MCP tool or resource to execute in milliseconds, set longer for long running tasks

            ---Chat-plugin related options-----------------
            auto_approve = false, -- Auto approve mcp tool calls
            auto_toggle_mcp_servers = true, -- Let LLMs start and stop MCP servers automatically

            --- Plugin specific options-------------------
            native_servers = {}, -- add your custom lua native servers here
            ui = {
                window = {
                    width = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
                    height = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
                    align = "center", -- "center", "top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right"
                    relative = "editor",
                    zindex = 50,
                    border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
                },
                wo = { -- window-scoped options (vim.wo)
                    winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
                },
            },
            on_ready = function(hub)
                -- Called when hub is ready
            end,
            on_error = function(err)
                -- Called on errors
            end,
            log = {
                level = vim.log.levels.WARN,
                to_file = false,
                file_path = nil,
                prefix = "MCPHub",
            },
        })
      end
    }
  '';
  # Claude Code plugin. coder/claudecode.nvim speaks the same WebSocket/MCP
  # protocol as the official VS Code / JetBrains extensions (inline diffs,
  # selection context, model select). Requires the `claude` CLI on PATH.
  # https://github.com/coder/claudecode.nvim
  xdg.configFile."nvim/lua/plugins/claude-code.lua".text = ''
    return {
      "coder/claudecode.nvim",
      dependencies = { "folke/snacks.nvim" }, -- already provided by LazyVim
      config = true,
      keys = {
        { "<leader>ai", "<cmd>ClaudeCode<cr>", desc = "Claude Code: toggle" },
        { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude Code: continue" },
        { "<leader>ay", "<cmd>ClaudeCode --resume<cr>", desc = "Claude Code: resume" },
        { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude Code: select model" },
        { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude Code: add current buffer" },
        { "<leader>av", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude Code: send selection" },
        {
          "<leader>av",
          "<cmd>ClaudeCodeTreeAdd<cr>",
          desc = "Claude Code: add file",
          ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
        },
        { "<leader>aj", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude Code: accept diff" },
        { "<leader>ak", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude Code: deny diff" },
      },
    }
  '';

  # Disable Mason on NixOS: LSPs/formatters/linters come from Nix (home.packages).
  xdg.configFile."nvim/lua/plugins/no-mason.lua".text = ''
    return {
      { "mason-org/mason.nvim", enabled = false },
      { "mason-org/mason-lspconfig.nvim", enabled = false },
    }
  '';

  # Let Neovim own the core parsers it bundles so nvim-treesitter's copies don't
  # shadow them (the vim "tab" query clash).
  xdg.configFile."nvim/lua/plugins/treesitter.lua".text = ''
    return {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        local bundled = {
          vim = true, vimdoc = true, c = true, lua = true,
          markdown = true, markdown_inline = true, query = true,
        }
        if type(opts.ensure_installed) == "table" then
          opts.ensure_installed = vim.tbl_filter(function(p)
            return not bundled[p]
          end, opts.ensure_installed)
        end
      end,
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

      extraPackages = with pkgs; [
        curl
        jq
        binutils # Provides tools like 'ld' for linking
      ];

      package = neovim-unwrapped;

      extraConfig = '''';
    }; # EOM neovim
  }; # EOM programs
}
# EOF
# vim: set ts=2 sw=2 et ai list nu

