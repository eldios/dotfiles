{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  sops.secrets = {
    "passwords/sox1x/eldios" = {
      sopsFile = "${secretspath}/sox1x.yaml";
      neededForUsers = true;
    };

    "passwords/sox1x/nimbina" = {
      sopsFile = "${secretspath}/sox1x.yaml";
      neededForUsers = true;
    };
  };

  users.users.nimbina = {
    shell = pkgs.bash;
    isNormalUser = true;

    hashedPasswordFile = config.sops.secrets."passwords/sox1x/nimbina".path;
    extraGroups = [
      "docker"
      "input"
      "uinput"
      "video"
      "wheel"
    ];

    openssh.authorizedKeys.keys = (
      lib.splitString "\n" (builtins.readFile ../../../common/files/authorized_keys)
    );
  };

  users.users.eldios = {
    hashedPasswordFile = config.sops.secrets."passwords/sox1x/eldios".path;
  };
}

# vim: set ts=2 sw=2 et ai list nu */
