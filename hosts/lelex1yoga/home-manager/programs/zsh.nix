{ pkgs, ... }:
{

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

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
