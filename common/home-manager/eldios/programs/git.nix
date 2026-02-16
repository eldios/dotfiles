{ pkgs, ... }:
let
  eldios_lazygit = pkgs.lazygit.overrideAttrs (oa: {
    version = "0.41.0";

    src = pkgs.fetchFromGitHub {
      owner = "jesseduffield";
      repo = "lazygit";
      rev = "4ba85608c8f3f25051994d3a7dd45647f58b119c";
      hash = "sha256-Ok6QnXw3oDeSzBekft8cDXM/YsADgF1NZznfNoGNvck=";
    };
  });
in
{
  home = {
    packages = with pkgs; [
      github-cli
    ];
  };

  programs = {

    lazygit = {
      enable = true;
      package = eldios_lazygit;
    }; # EOM lazygit

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        line-numbers = true;
        light = false;
      };
    }; # EOM delta

    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        alias = {
          co = "checkout";
          chp = "cherry-pick";
          lol = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
          loll = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
          ppt = "pull --prune --tags";
          prettylog = "...";
          rc = "repo clone";
          st = "status";
          w = "worktree";
          wK = "worktree unlock";
          wa = "worktree add";
          wk = "worktree lock";
          wl = "worktree list";
          wm = "worktree move";
          wr = "worktree remove";
        };
        advice = {
          skippedCherryPicks = false;
        };
        commit = {
          gpgsign = true;
        };
        tag = {
          gpgsign = true;
        };
        format = {
          signoff = true;
        };
        user = {
          username = "eldios";
          name = "Emanuele \"Lele\" Calo";
          email = "emanuele.lele.calo@gmail.com";
        };
        gpg = {
          program = "${pkgs.gnupg}/bin/gpg";
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
    }; # EOM git

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
