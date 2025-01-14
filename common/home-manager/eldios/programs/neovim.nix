{ pkgs, config, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  home = {
    packages = with pkgs; [
      # LSPs
      deno
      fd
      lua-language-server
      nil # Nix LSP
      nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      pyright
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
    ] ++ (with unstablePkgs; [ ] ++ [ ]);
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
            -- "gzip",
            -- "matchit",
            -- "matchparen",
            -- "netrwPlugin",
            -- "tarPlugin",
            -- "tohtml",
            -- "tutor",
            -- "zipPlugin",
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
    }
  '';
  xdg.configFile."nvim/lua/config/snacks.lua".text = ''
    return {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        notifier = {
          enabled = true,
          timeout = 3000,
        },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
          notification = {
            wo = { wrap = true } -- Wrap notifications
          }
        }
      },
      keys = {
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
        { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
        { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
        { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
        { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
        { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
        { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
        { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
        { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
        { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
        { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
        { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
        {
          "<leader>N",
          desc = "Neovim News",
          function()
            Snacks.win({
              file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
              width = 0.6,
              height = 0.6,
              wo = {
                spell = false,
                wrap = false,
                signcolumn = "yes",
                statuscolumn = " ",
                conceallevel = 3,
              },
            })
          end,
        }
      },
      init = function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "VeryLazy",
          callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
              Snacks.debug.inspect(...)
            end
            _G.bt = function()
              Snacks.debug.backtrace()
            end
            vim.print = _G.dd -- Override print to use snacks for `:=` command

            -- Create some toggle mappings
            Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
            Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
            Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
            Snacks.toggle.diagnostics():map("<leader>ud")
            Snacks.toggle.line_number():map("<leader>ul")
            Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
            Snacks.toggle.treesitter():map("<leader>uT")
            Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
            Snacks.toggle.inlay_hints():map("<leader>uh")
          end,
        })
      end,
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
  # https://github.com/olimorris/codecompanion.nvim
  xdg.configFile."nvim/lua/plugins/ai.lua".text = ''
    -- AI Configuration for NeoVim
    -- Using codecompanion with multiple AI providers
    -- Author: eldios
    -- Repository: https://github.com/eldios/.dotfiles

    -- Helper function to read API keys and configuration from files
    local function read_config_file(file_path)
      local file = io.open(file_path, "r")
      if file then
        local content = file:read("*all")
        file:close()
        -- Remove any whitespace and newlines
        return content:gsub("%s+", "")
      end
      vim.notify("Config file not found: " .. file_path, vim.log.levels.ERROR)
      return nil
    end

    -- Read configuration from files
    local anthropic_key = read_config_file("${config.sops.secrets."tokens/anthropic/key".path}");
    local gemini_key = read_config_file("${config.sops.secrets."tokens/gemini/key".path}");
    local openai_key = read_config_file("${config.sops.secrets."tokens/openai/key".path}");
    local ollama_key = read_config_file("${config.sops.secrets."tokens/ollama/key".path}");
    local ollama_url = read_config_file("${config.sops.secrets."tokens/ollama/url".path}");
    return {
      {
        "olimorris/codecompanion.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-treesitter/nvim-treesitter",
        },
        config = function()
          vim.keymap.set("v", "<leader>ccb", "", {
            callback = function()
              require("codecompanion").prompt("buffer")
            end,
            noremap = true,
            silent = true,
          })
          vim.keymap.set("v", "<leader>ccc", "", {
            callback = function()
              require("codecompanion").prompt("commit")
            end,
            noremap = true,
            silent = true,
          })
          vim.keymap.set("v", "<leader>cce", "", {
            callback = function()
              require("codecompanion").prompt("explain")
            end,
            noremap = true,
            silent = true,
          })
          vim.keymap.set("v", "<leader>ccf", "", {
            callback = function()
              require("codecompanion").prompt("fix")
            end,
            noremap = true,
            silent = true,
          })
          vim.keymap.set("v", "<leader>ccl", "", {
            callback = function()
              require("codecompanion").prompt("lsp")
            end,
            noremap = true,
            silent = true,
          })
          vim.keymap.set("v", "<leader>cct", "", {
            callback = function()
              require("codecompanion").prompt("tests")
            end,
            noremap = true,
            silent = true,
          })

          vim.keymap.set("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
          vim.keymap.set("n", "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })

          vim.keymap.set("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
          vim.keymap.set("v", "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
          vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

          -- Expand 'cc' into 'CodeCompanion' in the command line
          vim.cmd([[cab cc CodeCompanion]])

          require('codecompanion').setup{
            strategies = {
              chat = {
                adapter = "anthropic",
              },
              inline = {
                adapter = "anthropic",
              },
            },
            adapters = {
              gemini = function()
                return require("codecompanion.adapters").extend("gemini", {
                  env = {
                    api_key = gemini_key
                  }
                })
              end,
              anthropic = function()
                return require("codecompanion.adapters").extend("anthropic", {
                  env = {
                    api_key = anthropic_key
                  }
                })
              end,
              openai = function()
                return require("codecompanion.adapters").extend("openai", {
                  env = {
                    api_key = openai_key
                  }
                })
              end,
              ollama = function()
                return require("codecompanion.adapters").extend("ollama", {
                  schema = {
                    model = {
                      default = "llama3:8b",
                    },
                  },
                  env = {
                    url = ollama_url,
                    api_key = ollama_key,
                    chat_url = "/api/chat/completions",
                  },
                })
              end,
            },
          }
        end
      },
    }
  '';
  xdg.configFile."nvim/lua/plugins/lulz.lua".text = ''
    return {
      {
        "Eandrju/cellular-automaton.nvim",
      },
      {
        "tamton-aquib/duck.nvim",
        config = function()
          vim.keymap.set("n", "<leader>dd", function() require("duck").hatch("🐈") end, {})
          vim.keymap.set("n", "<leader>dk", function() require("duck").cook() end, {})
          vim.keymap.set("n", "<leader>da", function() require("duck").cook_all() end, {})
        end
      },
      {
        "AndrewRadev/discotheque.vim",
      },
      {
        "AndrewRadev/typewriter.vim",
      },
      {
        "rhysd/vim-syntax-christmas-tree",
      },
    }
  '';
  xdg.configFile."nvim/lua/plugins/markdown.lua".text = ''
    return {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        main = "render-markdown",
        name = "render-markdown",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        opts = {},
      },
      {
        "toppair/peek.nvim",
        event = { "VeryLazy" },
        build = "deno task --quiet build:fast",
        config = function()
            require("peek").setup({
              theme = 'dark',
              app = 'browser'
            })
            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end,
      },
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

      extraPackages = with pkgs; [
        curl
        jq
      ];

      package = unstablePkgs.neovim-unwrapped;

      plugins = with pkgs.vimPlugins; [ ];

      extraConfig = ''
      '';

      extraLuaConfig = ''
      '';
    }; # EOM neovim

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
