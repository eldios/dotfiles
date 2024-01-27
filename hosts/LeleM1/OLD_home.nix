{ config, pkgs, ... }:

{
  programs = {

    zsh = {
      enable                   = true;
      enableAutosuggestions    = true;
      enableCompletion         = true;

      syntaxHighlighting.enable = true;

      localVariables = {
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = true;
      };

      prezto = {
        enable = true;
        color = true;
        prompt = {
          theme = "powerlevel10k";
        };
        pmodules = [
          "environment"
          "terminal"
          "editor"
          "history"
          "directory"
          "spectrum"
          "utility"
          "completion"
          "prompt"
          "git"
        ];
      };

      shellAliases = {
        ls  = "colorls";
        ll  = "ls -lh";
        l   = "ls -lhtra";

        tf  = "terraform";
        tfp = "tf plan";
        tfa = "tf apply -auto-approve";
        tfd = "tf destroy -auto-approve";

        ipcalc    = "sipcalc";

        nixs      = "nix search nixpkgs";
        nixu      = "nix flake update $HOME/.config/home-manager";

        hm        = "home-manager";
        hmc       = "hm-cleanup";
        hme       = "hm-edit";
        hmu       = "hm-update";
        hmU       = "nixu && hm-update";
        hma       = "hme && hmu";
        hmA       = "hme && hmU";
        hm-cleanup= "home-manager expire-generations '-7 days' && nix-store --gc";
        hm-edit   = "home-manager edit";
        hm-update = "home-manager switch -b backup --flake '/Users/eldios/.config/home-manager/#eldios'";

        flyctl    = "/Users/eldios/.fly/bin/flyctl";

        SHX = "exec \$SHELL -l";
      };

      dirHashes = {
        dl = "$HOME/Downloads";
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

      initExtra = ''
        neofetch

        export EDITOR=/Users/eldios/.nix-profile/bin/nvim
        #export EDITOR=/Users/eldios/.nix-profile/bin/vim

        export PATH=$PATH:/opt/homebrew/bin
      '';

     initExtraBeforeCompInit = ''
       fpath+=("${config.home.profileDirectory}"/share/zsh/site-functions "${config.home.profileDirectory}"/share/zsh/$ZSH_VERSION/functions "${config.home.profileDirectory}"/share/zsh/vendor-completions)
     '';
    };

  };
}
