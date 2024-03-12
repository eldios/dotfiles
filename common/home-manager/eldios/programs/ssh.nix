{ config, pkgs, ... }:
{

  programs = {

    ssh = {
      enable      = true;
      compression = true;
      controlMaster = "yes";
      serverAliveInterval = 14;

      includes = [
        "~/.ssh/*.conf"
      ];
    }; # EOM ssh

  }; # EOM programs

  home.file.".ssh/defaults.conf".text = ''
    Host github.com
      User git

    Host aur.archlinux.org
      User aur

    Host *.lan *.caracal-great.ts.net
      User eldios
      IdentityFile ~/.ssh/id_ed25519
      AddKeysToAgent yes
      ForwardAgent yes

    Host *
      User root
      PasswordAuthentication yes
      ForwardAgent no
      ForwardX11 no
      ForwardX11Trusted no
  '';

} # EOF
# vim: set ts=2 sw=2 et ai list nu
