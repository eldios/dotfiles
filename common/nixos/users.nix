{ lib, pkgs, ... }:
{

  users.users.eldios = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "video"
    ];
    openssh.authorizedKeys.keys = (lib.splitString "\n" (builtins.readFile ../files/authorized_keys)) ;
  };

  users.users.root = {
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = (lib.splitString "\n" (builtins.readFile ../files/authorized_keys)) ;
  };
}
