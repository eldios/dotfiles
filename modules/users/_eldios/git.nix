{
  pkgs,
  lib,
  ...
}: {
  home = {
    packages = with pkgs;
      [
        github-cli
        lazygit
      ]
      ++ (with pkgs.unstable; [
        entire
      ]);
  };

  programs = {
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
          lol = "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) %C(bold magenta)%G?%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
          loll = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) %C(bold magenta)%G?%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n'' %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
          ppt = "pull --prune --tags";
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
        # user-level so GitButler cannot auto-disable signing repo-wide after
        # a single failed signature (its documented behavior with local scope)
        gitbutler = {
          signCommits = true;
        };
        tag = {
          gpgsign = true;
          forceSignAnnotated = true;
        };
        push = {
          default = "simple";
          gpgSign = "if-asked";
        };
        rebase = {
          gpgSign = true;
        };
        merge = {
          verifySignatures = false;
        };
        format = {
          signoff = true;
        };
        user = {
          username = "eldios";
          name = "Emanuele \"Lele\" Calo";
          email = "emanuele.lele.calo@gmail.com";
          # Default signing key; mininixos overrides in its per-host git.nix.
          signingkey = lib.mkDefault "AA6BC7743F8F9AD84BBA15C72CCBF4B71EFFDD46";
        };
        gpg = {
          program = "${pkgs.gnupg}/bin/gpg";
        };
        color = {
          ui = true;
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
}
# EOF
# vim: set ts=2 sw=2 et ai list nu

