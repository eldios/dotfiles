{ pkgs, ... }:
{

  users.users.eldios = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "video"
    ];
  };

  users.users.root = {
    shell = pkgs.bash;
    openssh.authorizedKeys = [
      (builtins.readFile ../files/authorized_keys)
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu */
