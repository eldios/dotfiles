{
  lib,
  pkgs,
  config,
  ...
}: {
  users.mutableUsers = false;

  # passwords/root is declared by the sops aspect.
  users.users.root = {
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets."passwords/root".path;

    openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../_assets/authorized_keys);
  };
}
