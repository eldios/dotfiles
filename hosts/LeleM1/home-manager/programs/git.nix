{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      lazygit
    ];
  };

  programs = {

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
          signinkey = "6F30847FEFC1F7D27043B4EF5929F08CDF8797F2" ;
          username = "eldios";
          name = "Emanuele \"Lele\" Calo";
          email = "emanuele.lele.calo@gmail.com ";
        };
        gpg = {
          program = "/Users/eldios/.nix-profile/bin/gpg" ;
        };
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
          light = false;
        };
      };
    }; # EOM git

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
