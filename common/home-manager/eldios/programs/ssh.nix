{ config, pkgs, ... }:
{

  programs = {

    ssh = {
      enable      = true;

      includes = [
        "~/.ssh/*.conf"
      ];

      extraConfig = ''
        Include ~/.ssh/*.conf
        Host github.com
          User git

        Host aur.archlinux.org
          User aur

        Host *.lan *.tailscale
          User eldios
          ForwardAgent yes

        Host *
          User root
          IdentityFile ~/.ssh/id_ed25519
          PasswordAuthentication yes
          Port 22
          AddKeysToAgent yes
          Compression yes
          ForwardAgent no
          ForwardX11 no
          ForwardX11Trusted no
          ServerAliveInterval 10
      '';
    }; # EOM ssh

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
