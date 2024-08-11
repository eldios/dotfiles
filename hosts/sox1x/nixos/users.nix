{ lib, pkgs, ... }:
{

  users.users.nimbina = {
    shell = pkgs.bash;
    isNormalUser = true;

    hashedPasswordFile = config.sops.secrets."passwords/sox1x/nimbina".path;
    extraGroups = [
      "wheel"
      "docker"
      "video"
    ];

    openssh.authorizedKeys.keys = (lib.splitString "\n" (builtins.readFile ../../../common/files/authorized_keys));
  };

  users.users.eldios = {
    hashedPasswordFile = config.sops.secrets."passwords/sox1x/eldios".path;
  };
}

# vim: set ts=2 sw=2 et ai list nu */
