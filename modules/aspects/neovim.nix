# Neovim on both sides: the system editor (vi/vim aliases, gruvbox, a
# minimal rc) and the LazyVim setup in the home with its Nix-provided
# language servers, formatters and AI plugins. The Lua files sit in
# _neovim/nvim, laid out as they appear in ~/.config/nvim.
let
  neovimPackage = pkgs:
    pkgs.unstable.neovim-unwrapped.overrideAttrs (old: {
      meta =
        old.meta or {}
        // {
          maintainers = [];
        };
    });
in {
  den.aspects.neovim = {
    nixos = {pkgs, ...}: {
      programs.neovim = {
        enable = true;
        defaultEditor = true;

        viAlias = true;
        vimAlias = true;

        package = neovimPackage pkgs;

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

    homeManager = {
      lib,
      pkgs,
      inputs,
      ...
    }: {
      home.packages = with pkgs; [
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

      # MCPHub servers configuration is managed by mcp-servers.nix, which
      # generates ~/.config/mcphub/servers.json pointing at the MCP hub
      xdg.configFile =
        lib.genAttrs [
          # Bootstraps lazy.nvim and LazyVim; LazyVim loads lua/config itself
          "nvim/init.lua"
          "nvim/lua/config/autocmds.lua"
          "nvim/lua/config/keymaps.lua"
          "nvim/lua/config/lazy.lua"
          "nvim/lua/config/options.lua"
          # Manual-only completion
          "nvim/lua/plugins/blink-cmp.lua"
          # coder/claudecode.nvim speaks the same WebSocket/MCP protocol as the
          # official VS Code and JetBrains extensions. Needs `claude` on PATH.
          "nvim/lua/plugins/claude-code.lua"
          # https://ravitemer.github.io/mcphub.nvim/installation.html#lazy-nvim
          "nvim/lua/plugins/mpc-hub.lua"
          # LSPs, formatters and linters come from home.packages
          "nvim/lua/plugins/no-mason.lua"
          # Neovim owns the core parsers it bundles, so nvim-treesitter's copies
          # do not shadow them (the vim "tab" query clash)
          "nvim/lua/plugins/treesitter.lua"
        ] (name: {
          text = builtins.readFile (./_neovim + "/${name}");
        });

      programs.neovim = {
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

        package = neovimPackage pkgs;
      };
    };
  };
}
