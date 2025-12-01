{
  pkgs,
  config,
  inputs,
  ...
}:
let
  neovim-unwrapped = pkgs.unstable.neovim-unwrapped.overrideAttrs (old: {
    meta = old.meta or { } // {
      maintainers = [ ];
    };
  });
in
{
  home = {
    packages =
      with pkgs;
      [
        # LLM related stuff
        aider-chat
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
      ]
      ++ (
        with pkgs.unstable;
        [ ]
        ++ [
          inputs.mpc-hub.packages."${pkgs.stdenv.hostPlatform.system}".default
        ]
      );
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
  # which generates ~/.config/mcphub/servers.json with SSE URLs
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
            shutdown_delay = 60 * 10 * 000, -- Delay in ms before shutting down the server when last instance closes (default: 10 minutes)
            use_bundled_binary = false, -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua")
            mcp_request_timeout = 60000, --Max time allowed for a MCP tool or resource to execute in milliseconds, set longer for long running tasks

            ---Chat-plugin related options-----------------
            auto_approve = false, -- Auto approve mcp tool calls
            auto_toggle_mcp_servers = true, -- Let LLMs start and stop MCP servers automatically
            extensions = {
                avante = {
                    make_slash_commands = true, -- make /slash commands from MCP server prompts
                }
            },

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
  # Claude Code plugin configuration
  xdg.configFile."nvim/lua/plugins/claude-code.lua".text = ''
    return {
      "greggh/claude-code.nvim",
      config = function()
        require("claude-code").setup({
          -- Command settings
          command = "claude",        -- Command used to launch Claude Code
          -- Command variants
          command_variants = {
            -- Conversation management
            claude = "", -- Resume the most recent conversation

            -- Conversation management
            continue = "--continue", -- Resume the most recent conversation

            -- Output options
            verbose = "--verbose",   -- Enable verbose logging with full turn-by-turn output
          },
          -- Keymaps
          keymaps = {
            toggle = {
              variants = {
                claude = "<leader>ac",   -- Normal mode keymap for Claude Code
                continue = "<leader>aC", -- Normal mode keymap for Claude Code with continue flag
                verbose = "<leader>aV",  -- Normal mode keymap for Claude Code with verbose flag
              },
            },
            window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
            scrolling = true,         -- Enable scrolling keymaps (<C-f/b>) for page up/down
          }
        })
      end,
    }
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
          provider = "qwen3coder",
          auto_suggestions_provider = "deepseekV3",
          providers = {

            --- SELF-HOSTED MODELS

            ollama = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/litellm/neovim/key".path}",
              endpoint = "https://litellm.lele.rip/v1",
              model = "ollama/ollama",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },

            --- CHEAP MODELS

            --- https://openrouter.ai/deepseek/deepseek-R1-0528
            --- $0.18/M input tokens $0.72/M output tokens
            deepseekR1 = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "deepseek/deepseek-r1-0528",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/deepseek/deepseek-chat-v3-0324
            --- $0.18/M input tokens $0.72/M output tokens
            deepseekV3 = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "deepseek/deepseek-chat-v3-0324",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/qwen/qwen3-coder
            --- $0.20/M input tokens || $0.80/M output tokens
            qwen3coder = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "qwen/qwen3-coder",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/moonshotai/kimi-k2
            --- $0.14/M input tokens || $2.49/M output tokens
            kimik2 = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "moonshotai/kimi-k2",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 120000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/google/gemini-2.5-flash
            --- $0.30/M input tokens || $2.50/M output tokens
            gemini25flash = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "google/gemini-2.5-flash",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/google/gemini-2.5-pro
            --- $1.25/M input tokens || $10/M output tokens
            gemini25pro = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "google/gemini-2.5-pro",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },

            --- AVG EXPENSIVE MODELS
            --- https://openrouter.ai/openai/gpt-4.1
            --- $2/M input tokens || $8/M output tokens
            gtp41 = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "openai/gpt-4.1",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/openai/gpt-5-chat
            --- $1.25/M input tokens || $10/M output tokens
            gtp5 = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "openai/gpt-5",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 512000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/anthropic/claude-3.7-sonnet
            --- $3/M input tokens || $15/M output tokens
            xaigrok4 = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "x-ai/grok-4",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 128000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 128000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },
            --- https://openrouter.ai/anthropic/claude-sonnet-4
            --- $3/M input tokens || $15/M output tokens
            claude4sonnet = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "anthropic/claude-sonnet-4",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 64000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 64000, -- Increase this to include reasoning tokens (for reasoning models)
                --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
              },
            },

            --- CRAZY EXPENSIVE MODELS

            --- https://openrouter.ai/anthropic/claude-opus-4
            --- $15/M input tokens || $75/M output tokens
            claude4opus = {
              __inherited_from = 'openai',
              api_key_name = "cmd:cat ${config.sops.secrets."tokens/openrouter/neovim/key".path}",
              endpoint = "https://openrouter.ai/api/v1",
              model = "anthropic/claude-opus-4",
              extra_request_body = {
                timeout = 120000, -- Timeout in milliseconds, increase this for reasoning models
                --temperature = 0.75,
                max_completion_tokens = 128000, -- Increase this to include reasoning tokens (for reasoning models)
                max_tokens = 128000, -- Increase this to include reasoning tokens (for reasoning models)
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
            first_provider = "claude4sonnet",
            second_provider = "xaigrok4",
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
            provider = "gemini25pro", -- The provider to use for RAG service (e.g. openai or ollama)
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
          -- system_prompt as function ensures LLM always has latest MCP server state
          -- This is evaluated for every message, even in existing chats
          system_prompt = function()
              local hub = require("mcphub").get_hub_instance()
              return hub and hub:get_active_servers_prompt() or ""
          end,
          -- Using function prevents requiring mcphub before it's loaded
          custom_tools = function()
              return {
                  require("mcphub.extensions.avante").mcp_tool(),
              }
          end,
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
          "nvim-mini/mini.pick", -- for file_selector provider mini.pick
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

      extraConfig = '''';

      extraLuaConfig = '''';
    }; # EOM neovim

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
