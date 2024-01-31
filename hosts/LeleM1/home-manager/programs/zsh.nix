{ config, pkgs, ... }:
{

  home = {
    packages = with pkgs; [
      # ZSH deps
      carapace
      thefuck
    ];
  };

  programs = {

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
        ZELLIJ_AUTO_ATTACH = false;
        ZELLIJ_AUTO_EXIT = false;
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

        nixu      = "nix flake update $HOME/.config/home-manager/.dotfiles";

        hm        = "home-manager";
        hmc       = "hm-cleanup";
        hme       = "hm-edit";
        hmu       = "hm-update";
        hmU       = "nixu && hm-update";
        hma       = "hme && hmu";
        hmA       = "hme && hmU";
        hm-cleanup= "home-manager expire-generations '-7 days' && nix-store --gc";
        hm-edit   = "home-manager edit";
        hm-update = "home-manager switch -b backup --flake '/Users/eldios/.config/home-manager/.dotfiles#eldios@LeleM1'";

        SHX = "exec \$SHELL -l";
      };

      shellGlobalAliases = {
        UUID = "$(uuidgen | tr -d \\n)";
        G = "| grep";
      };

      dirHashes = {
        dl = "$HOME/Downloads";
      };

      initExtra = ''
        #export EDITOR="$(which nvim)";
        #export VISUAL="$(which nvim)";

        neofetch

        zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
        source <(carapace _carapace zsh)

        eval "$(thefuck --alias)"
        eval "$(zoxide init zsh)"

        export PATH=$PATH:/opt/homebrew/bin
      '';

      initExtraBeforeCompInit = ''
        fpath+=("${config.home.profileDirectory}"/share/zsh/site-functions "${config.home.profileDirectory}"/share/zsh/$ZSH_VERSION/functions "${config.home.profileDirectory}"/share/zsh/vendor-completions)
      '';
    }; # EOM zsh

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
