{ config, pkgs, ... }:
{

  home = {
    packages = with pkgs; [
      neofetch
      carapace
      thefuck
      zoxide
      fzf
    ];
  }; # EOM ZSH deps

  programs = {

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable                   = true;
      enableAutosuggestions    = true;
      enableCompletion         = true;

      syntaxHighlighting = {
        enable = true;
      };

      localVariables = {
        TERM   = "xterm-256color";
        EDITOR = "${pkgs.neovim}/bin/nvim";
        VISUAL = "${pkgs.neovim}/bin/nvim";

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

      shellAliases = {
        ls  = "colorls";
        ll  = "ls -lh";
        l   = "ls -lhtra";

        g   = "git";
        lg  = "lazygit";

        # Kubectl
        k = "kubectl";
        j = "just";

        tf  = "terraform";
        tfp = "tf plan";
        tfa = "tf apply -auto-approve";
        tfd = "tf destroy -auto-approve";

        cg  = "cargo";
        cgb = "cg build";
        cgc = "cg check";
        cgn = "cg new";
        cgr = "cg run";
        cgt = "cg test";

        ipcalc     = "sipcalc";

        nixs       = "nix search nixpkgs";
        nixe       = "$EDITOR $HOME/.dotfiles/hosts/$(hostname)";

        nixu       = "sudo nixos-rebuild switch --impure --flake $HOME/.dotfiles";
        nixU       = "sudo nix flake update $HOME/.dotfiles && nixu";

        nixa       = "nixe && nixu";
        nixA       = "nixe && nixU";

        hm         = "home-manager";
        hmc        = "hm-cleanup";
        hme        = "hm-edit";
        hmu        = "hm-update";
        hmU        = "nixu && hm-update";
        hma        = "hme && hmu";
        hmA        = "hme && hmU";
        hm-cleanup = "home-manager expire-generations '-7 days' && nix-store --gc";
        hm-edit    = "home-manager edit";
        hm-update  = "home-manager switch -b backup --flake $HOME/.dotfiles'";

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
        zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
        source <(${pkgs.carapace}/bin/carapace _carapace zsh)

        eval "$(${pkgs.thefuck}/bin/thefuck --alias)"
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

        ${pkgs.neofetch}/bin/neofetch
      '';
    }; # EOM zsh

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
