{ pkgs, config, nixpkgs-unstable, ... }:
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
    ] ++ (with unstablePkgs; [
      aider-chat
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
    vim.opt.laststatus = 3
  '';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
  '';
  # this file is automatically loaded by LazyVim
  xdg.configFile."nvim/lua/config/autocmds.lua".text = ''
  '';
  # https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua
  xdg.configFile."nvim/lua/plugins/avante.lua".text = ''
    return {
      {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false, -- Never set this value to "*"! Never!
        build = "make",
        opts = {
          provider = "litellm",
          auto_suggestions_provider = "gemini",
          providers = {
            litellm = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/litellm/neovim/key".path}",
              endpoint = "https://litellm.lele.rip/v1",
              model = "openrouter/anthropic/claude-3-7-sonnet",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 32768, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            claude = {
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/anthropic/key".path}",
              endpoint = "https://api.anthropic.com",
              model = "claude-3-7-sonnet-latest",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 32768, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            openai = {
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openai/key".path}",
              endpoint = "https://api.openai.com/v1",
              model = "o3-mini",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 32768, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            gemini = {
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/gemini/key".path}",
              endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
              model = "gemini-2.5-pro",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 32768, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
          },
          ---Specify the special dual_boost mode
          ---1. enabled: Whether to enable dual_boost mode. Default to false.
          ---2. first_provider: The first provider to generate response. Default to "openai".
          ---3. second_provider: The second provider to generate response. Default to "claude".
          ---4. prompt: The prompt to generate response based on the two reference outputs.
          ---5. timeout: Timeout in milliseconds. Default to 60000.
          ---How it works:
          --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
          ---Note: This is an experimental feature and may not work as expected.
          dual_boost = {
            enabled = false,
            first_provider = "gemini",
            second_provider = "claude",
            prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
            timeout = 60000, -- Timeout in milliseconds
          },
          behaviour = {
            auto_apply_diff_after_generation = false,
            auto_focus_sidebar = true,
            auto_set_highlight_group = true,
            auto_set_keymaps = true,
            auto_suggestions = false,
            auto_suggestions_respect_ignore = true,
            enable_claude_text_editor_tool_mode = true, -- Whether to enable Claude Text Editor Tool Mode.
            enable_cursor_planning_mode = true, -- Whether to enable Cursor Planning Mode. Default to false.
            enable_token_counting = false, -- Whether to enable token counting. Default to true.
            jump_result_buffer_on_finish = true,
            minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
            support_paste_from_clipboard = true,
            use_cwd_as_project_root = true,
          },
          rag = {
            enabled = true, -- Enables the RAG service
            host_mount = os.getenv("HOME"), -- Host mount path for the rag service
            provider = "litellm", -- The provider to use for RAG service (e.g. openai or ollama)
            -- endpoint = "https://api.openai.com/v1", -- The API endpoint for RAG service
            -- llm_model = "", -- The LLM model to use for RAG service
            -- embed_model = "", -- The embedding model to use for RAG service
          },
          web_search_engine = {
            provider = "kagi", -- tavily, serpapi, searchapi, google or kagi
            providers = {
              kagi = {
                api_key_name = "cmd:cat ${config.sops.secrets."tokens/kagi/key".path}",
              },
            },
          },
        },
        mappings = {
          --- @class AvanteConflictMappings
          diff = {
            ours = "co",
            theirs = "ct",
            all_theirs = "ca",
            both = "cb",
            cursor = "cc",
            next = "]x",
            prev = "[x",
          },
          suggestion = {
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
          jump = {
            next = "]]",
            prev = "[[",
          },
          submit = {
            normal = "<CR>",
            insert = "<C-s>",
          },
          cancel = {
            normal = { "<C-c>", "<Esc>", "q" },
            insert = { "<C-c>" },
          },
          sidebar = {
            apply_all = "A",
            apply_cursor = "a",
            retry_user_request = "r",
            edit_user_request = "e",
            switch_windows = "<Tab>",
            reverse_switch_windows = "<S-Tab>",
            remove_file = "d",
            add_file = "@",
            close = { "<Esc>", "q" },
            close_from_input = nil, -- e.g., { normal = "<Esc>", insert = "<C-d>" }
          },
        },
        hints = { enabled = true },
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "stevearc/dressing.nvim",
          "nvim-lua/plenary.nvim",
          "MunifTanjim/nui.nvim",
          --- The below dependencies are optional,
          "echasnovski/mini.pick", -- for file_selector provider mini.pick
          --- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
          "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
          --- "ibhagwan/fzf-lua", -- for file_selector provider fzf
          "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
          --- "zbirenbaum/copilot.lua", -- for providers='copilot'
          {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
              -- recommended settings
              default = {
                embed_image_as_base64 = true,
                prompt_for_file_name = true,
                drag_and_drop = {
                  insert_mode = true,
                },
                use_absolute_path = true,
              },
            },
          },
          {
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
              file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
          },
        },
      }
    }
  '';
  # https://github.com/olimorris/codecompanion.nvim
  # https://github.com/eldios/codecompanion.nvim
  xdg.configFile."nvim/lua/plugins.disabled/codecompanion.lua".text = ''
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
    local litellm_key = read_config_file("${config.sops.secrets."tokens/litellm/neovim/key".path}");
    local litellm_url = read_config_file("${config.sops.secrets."tokens/litellm/neovim/url".path}");
    return {
      {
        "eldios/codecompanion.nvim",
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
                adapter = "litellm",
              },
              inline = {
                adapter = "litellm",
              },
              cmd = {
                adapter = "litellm",
              },
            },
            adapters = {
              litellm = function()
                return require("codecompanion.adapters").extend("openai_compatible", {
                  name = "litellm",
                  schema = {
                    model = {
                      default = "anthropic/claude-3-7-sonnet-latest",
                    },
                  },
                  env = {
                    api_key = litellm_key,
                    url = litellm_url,
                  }
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
        gcc # For compiling Avante components
        gnumake # Required for Avante build process
        binutils # Provides tools like 'ld' for linking
      ];

      package = neovim-unwrapped;

      plugins = with pkgs.vimPlugins; [
        avante-nvim
      ];

      extraConfig = ''
      '';

      extraLuaConfig = ''
      '';
    }; # EOM neovim

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
