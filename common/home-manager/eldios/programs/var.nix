{
  programs = {

    command-not-found.enable = false; # mutually exclusive with nix-index
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    dircolors.enable = true;
    htop.enable = true;
    info.enable = true;
    jq.enable = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    }; # EOM zfz

    bat = {
      enable = true;
    }; # EOM bat

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    }; # EOM direnv

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
