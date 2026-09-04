# Second local account on sox1x: a plain bash login with the shared ssh keys
# and its own password from the host's secrets file. No Home Manager: the
# host declares it with classes = ["user"].
{
  den,
  inputs,
  lib,
  ...
}: let
  authorizedKeys = lib.splitString "\n" (builtins.readFile ../_assets/authorized_keys);
in {
  den.aspects.nimbina = {
    includes = [
      den.batteries.define-user
      (den.batteries.user-shell "bash")
    ];

    nixos = {
      host,
      user,
      config,
      ...
    }: let
      secret = "passwords/${host.name}/${user.userName}";
    in {
      sops.secrets.${secret} = {
        sopsFile = "${toString inputs.secrets}/${host.name}.yaml";
        neededForUsers = true;
      };

      users.users.${user.userName} = {
        hashedPasswordFile = config.sops.secrets.${secret}.path;

        extraGroups = [
          "docker"
          "input"
          "uinput"
          "video"
          "wheel"
        ];

        openssh.authorizedKeys.keys = authorizedKeys;
      };
    };
  };
}
