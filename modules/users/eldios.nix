# The primary account on every host: admin groups, the shared ssh keys, the
# login password from the host's own secrets file, and the Home Manager base
# every host gives it (secrets, user services, git, ssh).
{
  den,
  inputs,
  lib,
  ...
}: let
  authorizedKeys = lib.splitString "\n" (builtins.readFile ../_assets/authorized_keys);
in {
  den.aspects.eldios = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
      (den.batteries.user-shell "zsh")
      # The host picks its feature aspects; the user living on it receives
      # their Home Manager half.
      den.batteries.host-aspects
      # The shell and CLI toolset follows the user onto every host.
      den.aspects.cli
    ];

    nixos = {
      host,
      user,
      config,
      lib,
      ...
    }: let
      sopsFile = "${toString inputs.secrets}/${host.name}.yaml";
      secret = "passwords/${host.name}/${user.userName}";
      # sops keeps key names in the clear, so the host's own secrets file says
      # whether it holds a login password; a headless host stays key-only.
      hasPassword = lib.hasInfix "\npasswords:" ("\n" + builtins.readFile sopsFile);
    in {
      sops.secrets = lib.optionalAttrs hasPassword {
        ${secret} = {
          inherit sopsFile;
          neededForUsers = true;
        };
      };

      users.users.${user.userName} =
        {
          extraGroups = [
            "dialout"
            "docker"
            "input"
            "libvirt"
            "uinput"
            "video"
          ];

          openssh.authorizedKeys.keys = authorizedKeys;
        }
        // lib.optionalAttrs hasPassword {
          hashedPasswordFile = config.sops.secrets.${secret}.path;
        };
    };

    homeManager.imports = [
      ./_eldios/sops.nix
      ./_eldios/services.nix
      ./_eldios/git.nix
      ./_eldios/ssh.nix
    ];
  };
}
