{ pkgs, ... }:
{

  home = {
    stateVersion = "24.05";

    file = { };

    sessionVariables = {
      TERM = "xterm-256color";
    };

    packages = with pkgs; [
      # CLI utils
      asciiquarium
      awscli2
      bombadillo
      btop
      cava
      cavalier
      cbonsai
      cmatrix
      cointop
      colorls
      cowsay
      figlet
      flameshot
      fortune
      gcal
      github-cli
      glances
      graph-easy
      graphviz
      iotop
      just
      lolcat
      mtr
      networkmanager
      ncdu
      neofetch
      nyancat
      parallel
      pciutils
      pdfposter
      playerctl
      pls
      pv
      pwgen
      ranger
      ripgrep-all
      sipcalc
      thefuck
      tldr
      tmux
      toilet
      wmctrl
      whois
      yubikey-personalization

      # DevOps Experimental stuff
      devspace
      devpod
      skaffold
      helmfile
      terracognita
      terraform
      terraform-compliance
      terraform-landscape
      terraformer
      terraforming
      terragrunt
      terraspace
      terraform-ls
      tflint
      tflint-plugins.tflint-ruleset-aws
      tfswitch
      vcluster

      # DevOps (Kubernetes, Terraform, etc..) stuff
      eksctl
      k9s
      kind
      kubectl
      kubelogin
      kubelogin-oidc
      kubernetes-helm
      nodejs
      bun
      nodenv
      temporal-cli
      tfk8s
      yamlfmt
      yamllint

      # charm.sh CLI utils
      gum
      vhs
      glow
      mods
      zfxtop

      # nix stuff
      cachix # adding/managing alternative binary caches hosted by Cachix
      comma # run software from without installing it
      niv # easy dependency management for nix projects
      nix-prefetch-git
      nix-prefetch-github
      nixfmt
      nodePackages.node2nix
      prefetch-npm-deps

      # nvim stuff
      carapace
      rnix-lsp
      terraform-ls
      terraform-lsp
      typescript

      # GUI stuff
      cryptomator
      discord
      light # brightness control
      paperview
      redshift
      kitty
      spotify
      variety
      vesktop # discord + some fixes
      vivaldi # preferred browser
      vivaldi-ffmpeg-codecs # codecs for vivaldi
      vscode

      # fonts
      anonymousPro
      meslo-lgs-nf
      font-awesome
      nerdfonts
      fira-code-nerdfont

      # BEGIN Sway confguration
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      #dbus-sway-environment
      #configure-gtk
      wayland
      xdg-utils # for opening default programs when clicking links
      dracula-theme # gtk theme
      gnome3.adwaita-icon-theme  # default gnome cursors
      swaylock
      swayidle
      shotman
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      bemenu # wayland clone of dmenu
      mako # notification system developed by swaywm maintainer
      wdisplays # tool to configure displays
    ];
  }; # EOM home

  xdg.portal = {
    enable = true;
    #wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    config.common.default = "*" ;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;

    extraConfig = ''
      # set background
      #output "*" bg IMAGE_FILE fill
    '';
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "alacritty"; 
      output = {
        "Virtual-1" = {
          mode = "1920x1080@60Hz";
        };
      };
      startup = [
        # Launch Firefox on start
        {
          command = "alacritty";
        }
      ];
    };
  };

  # EOM Sway confguration

  # # i3 config
  # xsession.windowManager.i3 = {
  #   enable = true;
  #   config = {
  #     modifier = "Mod4" ;
  #   };
  # };

  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "curses";

      enableSshSupport = true;
      enableZshIntegration = true;

      extraConfig = ''
        #debug-pinentry
        #debug ipc
        #debug-level 1024

        # I don't use smart cards
        disable-scdaemon
      '';
    };
  }; # EOM services

  programs = {
    home-manager = {
      enable = true;
    };

    bash.enable = true;

    command-not-found.enable = false; # mutually exclusive with nix-index
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    dircolors.enable = true;
    eza.enable       = true;
    htop.enable      = true;
    info.enable      = true;
    jq.enable        = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    }; # EOM zfz

    bat = {
      enable = true;
      config = {
        theme = "GitHub";
        italic-text = "always";
      };
    }; # EOM bat

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    }; # EOM direnv

    alacritty = {
      enable = true;
      settings = {
        font = {
          size = 11.0;
          normal = {
            family = "MesloLGS NF";
            style = "Regular";
          };
        };
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraConfig = ''
        set modeline

        " Config using Vim syntax
        nnoremap <space>ff <cmd>Telescope find_files<cr>
        nnoremap <space>fg <cmd>Telescope live_grep<cr>
        nnoremap <space>fb <cmd>Telescope buffers<cr>
        nnoremap <space>fh <cmd>Telescope help_tags<cr>

        " colorscheme gruvbox-material
        colorscheme material-darker
        " source ~/.config/nvim/themes/argonaut.vim
        syntax on

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

          lsp.tflint.setup {}

          -- Terraform setup
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

        # Treesitter code highlighting and more
        nvim-treesitter.withAllGrammars

        # Eyecandy
        gruvbox-material # theme & colors
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

    zsh = {
      enable                   = true;
      enableAutosuggestions    = true;
      enableCompletion         = true;

      syntaxHighlighting = {
        enable = true;
      };

      localVariables = {
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
        POWERLEVEL10K_DISABLE_CONFIGURATION_WIZARD = true;
      };

      history = {
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
        ignorePatterns = [
          "pkill"
        ];
        share = true;
      };

      prezto = {
        enable = true;
        color = true;
        prompt = {
          theme = "powerlevel10k";
          pwdLength = "short";
        };
        pmodules = [
          "completion"
          "directory"
          "docker"
          "editor"
          "environment"
          "git"
          "history"
          "prompt"
          "spectrum"
          "terminal"
          "utility"
        ];
      };

      shellAliases = {
        ls  = "colorls";
        ll  = "ls -lh";
        l   = "ls -lhtra";

        g   = "git";

        # Kubectl
        k = "kubectl";
        j = "just";

        tf  = "terraform";
        tfp = "tf plan";
        tfa = "tf apply -auto-approve";
        tfd = "tf destroy -auto-approve";

        ipcalc    = "sipcalc";

        nixs      = "nix search nixpkgs";

        nixe      = "nvim /etc/nixos/home.nix";

        nixu      = "sudo nixos-rebuild switch";
        nixU      = "sudo nix flake update /etc/nixos && nixu";

        nixa      = "nixe && nixu";
        nixA      = "nixe && nixU";

        hm-cleanup= "home-manager expire-generations '-7 days' && nix-store --gc";
        hm-edit   = "home-manager edit";

        SHX = "exec \$SHELL -l";
      };

      shellGlobalAliases = {
        UUID = "$(uuidgen | tr -d \\n)";
        G = "| grep";
      };

      dirHashes = {
        dl = "$HOME/Downloads";
        platform = "$HOME/go/src/github.com/tint-ai/tint-platform";
        infra = "$HOME/go/src/github.com/tint-ai/infra";
      };

      initExtra = ''
        export TERM="xterm-256color";
        export EDITOR="$(which nvim)";
        export VISUAL="$(which nvim)";

        neofetch

        zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
        source <(carapace _carapace zsh)

        eval $(thefuck --alias)
      '';

      /* FIXME
      initExtraBeforeCompInit = ''
      fpath+=("${config.home.profileDirectory}"/share/zsh/site-functions "${config.home.profileDirectory}"/share/zsh/$ZSH_VERSION/functions "${config.home.profileDirectory}"/share/zsh/vendor-completions)
      '';
      */
    }; # EOM zsh

    git = {
      enable = true;
      aliases = {
        st   = "status" ;
        co   = "checkout" ;
        rc   = "repo clone" ;
        ppt  = "pull --prune --tags" ;
        lol  = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green    )(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all" ;
        loll = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C    (bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all" ;
        prettylog = "...";
      };
      extraConfig = {
        advice = {
          skippedCherryPicks = false ;
        };
        commit = {
          gpgsign = true;
        };
        user = {
          signinkey = "64F87759366D72D60055C0BD3EDE14869955C119";
          username = "eldios";
          name = "Emanuele \"Lele\" Calo";
          email = "emanuele.lele.calo@gmail.com ";
        };
        #gpg = {
        #  program = "/Users/eldios/.nix-profile/bin/gpg" ;
        #};
        color = {
          ui = true;
        };
        push = {
          default = "simple";
        };
        pull = {
          ff = "only";
        };
        init = {
          defaultBranch = "main";
        };
      };

      ignores = [
        ".DS_Store"
        "*.pyc"
      ];
      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
        };
      };
    }; # EOM git
  }; # EOM programs

} # EOF

# vim: set ts=2 sw=2 et ai list nu */
