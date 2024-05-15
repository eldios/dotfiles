{ pkgs, ... }:
let
  eldios-ssh-agents = pkgs.ssh-agents.overrideAttrs (oa: {
    src = pkgs.fetchgit {
      url = "https://github.com/eldios/ssh-agents";
      rev = "a34bd5f495ee6bb34c24f02904db520a6c84ae0b";
      hash = "sha256-chkTgr9kzOdAS9zvKuZ5XKvbk9nrk8dkugRQxEiZqBI=";
    };
  });
in
{
  home = {
    packages = [
      eldios-ssh-agents
    ];
  }; # EOM ZSH deps

  programs.zsh.profileExtra = ''
    eval "$(ssh-agents -c -a ~/.ssh/id_ed25519)"
  '';

} # EOF
# vim: set ts=2 sw=2 et ai list nu
