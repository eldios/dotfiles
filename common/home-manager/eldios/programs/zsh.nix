{ pkgs, ... }:
let
  myFastFetchOpt = "-s 'Title:Separator:OS:Host:Uptime:Separator:Packages:Kernel:Shell:WM:Terminal:TerminalFont:Separator:CPU:GPU:Memory:Swap:Disk:LocalIp'";
in
{

  home = {
    packages = with pkgs; [
      carapace
      fastfetch
      fzf
      lsd
      thefuck
      zoxide
    ];
  }; # EOM ZSH deps

  programs = {

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion = {
        enable = true;
      };

      syntaxHighlighting = {
        enable = true;
      };

      localVariables = {
        TERM = "xterm-256color";
        EDITOR = "$(which nvim)";
        VISUAL = "$(which nvim)";

        ZELLIJ_AUTO_ATTACH = false;
        ZELLIJ_AUTO_EXIT = false;

        SOPS_AGE_KEY_FILE = "/etc/sops/key.txt";
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

      shellAliases = {
        ls = "${pkgs.lsd}/bin/lsd";
        ll = "${pkgs.lsd}/bin/lsd -lh";
        l = "${pkgs.lsd}/bin/lsd -lhtra";

        b = "${pkgs.gitbutler}/bin/but-cli";
        g = "${pkgs.git}/bin/git";
        lg = "${pkgs.lazygit}/bin/lazygit";
        lazg = "${pkgs.lazygit}/bin/lazygit";
        lazd = "${pkgs.lazydocker}/bin/lazydocker";

        f = "${pkgs.superfile}/bin/superfile";
        m = "${pkgs.inlyne}/bin/inlyne -t dark -s 1.5";
        n = "${pkgs.nnn}/bin/nnn";
        y = "${pkgs.yazi}/bin/yazi";

        # Kubectl
        k = "${pkgs.kubectl}/bin/kubectl";
        j = "${pkgs.just}/bin/just";

        ji = "${pkgs.jira-cli-go}/bin/jira issue";
        jil = "ji list"; # Uses the 'ji' alias
        jim = "ji list -a lele@switchboard.xyz --order-by STATUS"; # Uses the 'ji' alias

        TF = "${pkgs.terraform}/bin/terraform";
        tf = "${pkgs.opentofu}/bin/tofu";
        tfp = "tf plan"; # Uses the 'tf' alias
        tfa = "tf apply -auto-approve"; # Uses the 'tf' alias
        tfd = "tf destroy -auto-approve"; # Uses the 'tf' alias

        cg = "${pkgs.cargo}/bin/cargo";
        cgb = "cg build"; # Uses the 'cg' alias
        cgc = "cg check"; # Uses the 'cg' alias
        cgn = "cg new"; # Uses the 'cg' alias
        cgr = "cg run"; # Uses the 'cg' alias
        cgt = "cg test"; # Uses the 'cg' alias

        ipcalc = "${pkgs.sipcalc}/bin/sipcalc";
        ff = "${pkgs.fastfetch}/bin/fastfetch ${myFastFetchOpt}";

        nixs = "nix search nixpkgs"; # 'nix' assumed in PATH
        nixe = "$EDITOR $HOME/dotfiles"; # Uses $EDITOR variable

        nixu = "sudo nixos-rebuild switch --flake $HOME/dotfiles"; # 'sudo' and 'nixos-rebuild' assumed in PATH
        nixuo = "sudo nixos-rebuild switch --flake $HOME/dotfiles --option substituters 'https://cache.nixos.org https://nix-community.cachix.org'"; # offline/outside - skip local cache
        nixU = "sudo nix flake update $HOME/dotfiles && nixu"; # 'sudo', 'nix', and 'nixu' alias
        nixUo = "sudo nix flake update $HOME/dotfiles && nixuo"; # 'sudo', 'nix', and 'nixuo' alias - outside network

        nixa = "nixe && nixu"; # Uses aliases
        nixA = "nixe && nixU"; # Uses aliases

        hm = "${pkgs.home-manager}/bin/home-manager";
        hmc = "hm-cleanup"; # Uses 'hm-cleanup' alias which calls 'hm'
        hme = "hm-edit"; # Uses 'hm-edit' alias which calls 'hm'
        hmu = "hm-update"; # Uses 'hm-update' alias which calls 'hm'
        hmU = "nixu && hm-update"; # Uses aliases
        hma = "hme && hmu"; # Uses aliases
        hmA = "hme && hmU"; # Uses aliases
        hm-cleanup = "hm expire-generations '-7 days' && nix-store --gc"; # Uses 'hm' alias, 'nix-store' in PATH
        hm-edit = "hm edit"; # Uses 'hm' alias
        hm-update = "hm switch -b backup --flake $HOME/dotfiles"; # Uses 'hm' alias

        SHX = "exec \$SHELL -l"; # Uses $SHELL environment variable
      };

      shellGlobalAliases = {
        UUID = "$(uuidgen | tr -d \\n)";
        G = "| grep";
      };

      dirHashes = {
        nix = "$HOME/dotfiles";
        dl = "$HOME/Downloads";
        tmp = "$HOME/tmp";
        gh = "$HOME/go/src/github.com";
        gheldios = "$HOME/go/src/github.com/eldios";
        ghsw = "$HOME/go/src/github.com/switchboard-xyz";
        ghlinera = "$HOME/go/src/github.com/linera-io";
      };

      initContent = ''
        bindkey '^P' history-beginning-search-backward
        bindkey '^N' history-beginning-search-forward

        zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
        source <(${pkgs.carapace}/bin/carapace _carapace zsh)

        eval "$(${pkgs.thefuck}/bin/thefuck --alias)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        ${pkgs.fastfetch}/bin/fastfetch ${myFastFetchOpt}

        # Source local configuration if it exists
        if [[ -f "$HOME/.config/zsh/zshrc.local" ]]; then
          source "$HOME/.config/zsh/zshrc.local"
        fi
      '';
    }; # EOM zsh

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
