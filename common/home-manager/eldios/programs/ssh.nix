{

  home.file.".ssh/authorized_keys".source = ../../../files/authorized_keys;

  home.file.".ssh/config".text = ''
    Include ~/.ssh/*.conf

    Include ~/.ssh/hosts.conf

    Include ~/.ssh/defaults.conf
  '';

  home.file.".ssh/defaults.conf".text = ''
    Host github.com
      User git
      IdentityFile ~/.ssh/id_ed25519
      IdentitiesOnly no

    Host aur.archlinux.org
      User aur
      IdentityFile ~/.ssh/aur_id_ed25519

    Host *.lan *.caracal-great.ts.net
      User eldios
      IdentityFile ~/.ssh/id_ed25519
      AddKeysToAgent yes
      ForwardAgent yes

    # apply to all hosts that have gone through canonicalization
    Match canonical all

    # apply to all hosts
    Match all
      User root
      PasswordAuthentication yes
      ForwardAgent no
      ForwardX11 no
      ForwardX11Trusted no
      IdentitiesOnly yes
      PreferredAuthentications publickey,password
      Compression yes
      ServerAliveInterval 14
      ServerAliveCountMax 3
      HashKnownHosts yes
      UserKnownHostsFile ~/.ssh/known_hosts
      ControlMaster auto
      ControlPath ~/.ssh/master-%r@%n:%p
      ControlPersist 30m
  '';

} # EOF
# vim: set ts=2 sw=2 et ai list nu
