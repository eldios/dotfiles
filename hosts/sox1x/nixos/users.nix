{ lib, pkgs, ... }:
{

  users.users.nimbina = {
    shell = pkgs.bash;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "video"
    ];

    openssh.authorizedKeys.keys = (lib.splitString "\n" (builtins.readFile ../../../common/files/authorized_keys)) ;
  };
}

# vim: set ts=2 sw=2 et ai list nu */
