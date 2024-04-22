{ pkgs, ... }:
let
  eldios-ssh-agents = pkgs.ssh-agents.overrideAttrs (oa: {
    src = pkgs.fetchgit {
      url = "https://github.com/eldios/ssh-agents";
      rev = "fbe5ce9a36830e53e9f20f5145425ce2dc2c215c";
      hash = "sha256-/aruWXzC2ZbW+1v8S97MED6UOKPeDGcJzdNKX+wUfsw=";
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
    eval "$(ssh-agents -A -c)"
  '';

} # EOF
# vim: set ts=2 sw=2 et ai list nu
