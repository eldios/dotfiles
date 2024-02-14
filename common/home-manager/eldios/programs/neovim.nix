{ pkgs, ... }:
{

  home = {
    packages = with pkgs; [
      # Golang
      go
      # Rust
      #rustup
      cargo
      rust-analyzer
      rustc
      rustfmt
      # Haskell
      ghc
      haskell-language-server
      # vars
      ripgrep     # used by space-f-g
      ripgrep-all # used by space-f-g
    ];
  };

  programs = {

    neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = with pkgs; [
        rnix-lsp
      ];

      extraConfig = ''
        set modeline
        nnoremap <space>cc <cmd>CodeiumEnable<cr>
        nnoremap <space>cC <cmd>CodeiumDisable<cr>

        " Config using Vim syntax
        nnoremap <space>ff <cmd>Telescope find_files<cr>
        nnoremap <space>fg <cmd>Telescope live_grep<cr>
        nnoremap <space>fb <cmd>Telescope buffers<cr>
        nnoremap <space>fh <cmd>Telescope help_tags<cr>

        nnoremap <space>fr <cmd>Telescope lsp_references<cr>
        nnoremap <space>fd <cmd>Telescope lsp_definitions<cr>
        nnoremap <space>fi <cmd>Telescope lsp_implementations<cr>

        " Rust key-bindings
        nnoremap <space>rr <cmd>RustRun<cr>
        nnoremap <space>rf <cmd>RustFmt<cr>
        nnoremap <space>rF <cmd>RustFmtRange<cr>

        colorscheme material-darker

        syntax enable
        filetype plugin indent on

        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nu numberwidth=4 list cc=80
        set tw=78 sw=2 ts=2 sts=2 expandtab
        set smartindent
        set noswapfile nobackup
        set undodir=~/.config/nvim/undodir undofile
        set incsearch nohlsearch ignorecase smartcase
        set nowrap splitbelow splitright
        set hidden noshowmode scrolloff=8
        set updatetime=250 encoding=UTF-8 mouse=a
        set conceallevel=0

        " https://github.com/rust-lang/rust.vim/issues/461
        " set shell=${pkgs.bash}/bin/bash

        " Config using LUA Syntax
        lua << EOF
          -- Treesitter syntax-highlighting
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            },
            incremental_selection = {
              enable = true,
            },
          }

          -- CMP setup
          local cmp = require'cmp'
          cmp.setup.cmdline('/',{
            sources = {{ name = 'buffer' }}
          })
          cmp.setup.cmdline(':',{
              {{ name = 'path' }},
              {{ name = 'cmdline' }},
          })

          cmp.setup {
            mappings = {
              ['<CR>']  = cmp.mapping(cmp.mapping.confirm{select = true}),
              ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
              ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4),  { 'i', 'c' }),
              ['<C-y>'] = cmp.config.disable,
              ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
              ['<C-e>'] = cmp.mapping({
                i = cmp.mapping.abort(),
                c = cmp.mapping.close(),
              }),
            },
            sources = {
              {{ name = 'nvim_lsp' }},
              {{ name = 'buffer'   }},
            }
          }

          -- additional plugins
          require'bufferline'.setup {}
          require'toggleterm'.setup {}
          require'dashboard'.setup {}

          -- common LSP setup
          local lsp = require'lspconfig'

          -- rnix LSP
          lsp.rnix.setup {}

          -- Terraform LSP
          lsp.terraformls.setup {
            cmd = {
              'terraform-ls', 'serve'
            },
          }

          -- Rust Setup
          local nvim_lsp = require'lspconfig'

          local on_attach = function(client)
              require'completion'.on_attach(client)
          end

          nvim_lsp.rust_analyzer.setup({
              on_attach=on_attach,
              settings = {
                  ["rust-analyzer"] = {
                      imports = {
                          granularity = {
                              group = "module",
                          },
                          prefix = "self",
                      },
                      cargo = {
                          buildScripts = {
                              enable = true,
                          },
                      },
                      procMacro = {
                          enable = true
                      },
                  }
              }
          })

          -- Terraform setup
          lsp.tflint.setup {}

          vim.cmd([[silent! autocmd! filetypedetect BufRead,BufNewFile *.tf]])
          vim.cmd([[autocmd BufRead,BufNewFile *.hcl set filetype=hcl]])
          vim.cmd([[autocmd BufRead,BufNewFile .terraformrc,terraform.rc set filetype=hcl]])
          vim.cmd([[autocmd BufRead,BufNewFile *.tf,*.tfvars set filetype=terraform]])
          vim.cmd([[autocmd BufRead,BufNewFile *.tfstate,*.tfstate.backup set filetype=json]])
          vim.cmd([[let g:terraform_fmt_on_save=1]])
          vim.cmd([[let g:terraform_align=1]])

          -- nVim Global mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

          -- Use LspAttach autocommand to only map the following keys
          -- after the language server attaches to the current buffer
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
              -- Enable completion triggered by <c-x><c-o>
              vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

              -- Buffer local mappings.
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              local opts = { buffer = ev.buf }
              vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
              vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
              vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
              vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
              vim.keymap.set('n', 'gw', vim.lsp.buf.document_symbol, opts)
              vim.keymap.set('n', 'gW', vim.lsp.buf.workspace_symbol, opts)
              vim.keymap.set('n', 'K',  vim.lsp.buf.hover, opts)
              vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

              vim.keymap.set('n',          '<space>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)

              vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
              vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
              vim.keymap.set('n', '<space>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end, opts)

              -- format the currrent buffer
              vim.keymap.set('n', '<space>f', function()
                vim.lsp.buf.format { async = true }
              end, opts)
            end,
          })
        EOF
      '';

      plugins = with pkgs.vimPlugins; [
        # Codeium VIM plugin
        codeium-vim

        # Terraform
        vim-terraform

        # Git tool
        vim-fugitive
        vim-gitgutter

        # File tree
        nvim-web-devicons
        neo-tree-nvim # super fancy file explorer

        # Telescope - https://github.com/nvim-telescope/telescope.nvim
        telescope-nvim # super powerful fuzzy finder - needs more conf

        # LSP and auto completion - not working entirely
        nvim-lspconfig #
        nvim-cmp #
        cmp-buffer #
        cmp-path #
        cmp-cmdline #
        cmp-nvim-lsp #
        rust-vim

        # Treesitter code highlighting and more
        nvim-treesitter.withAllGrammars

        # Eyecandy
        gruvbox-material # theme & colors
        gruvbox          # theme & colors
        material-nvim
        indentLine # show indentLine vertical lines
        bufferline-nvim # fancy buffer line with tags support

        # Misc
        toggleterm-nvim # better terminal management
        dashboard-nvim # fancy startup dashboard, alternative to startup-nvim
        plenary-nvim # a NeoVim LUA functions library
        undotree # better Undo with Git-like DAG
        mini-nvim # 25+ plugins all in one
        vim-bookmarks
      ];
    }; # EOM neovim

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
