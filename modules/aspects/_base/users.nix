{
  lib,
  pkgs,
  config,
  ...
}: {
  users.mutableUsers = false;

  # Users and groups come from userborn, a systemd unit that runs before
  # sysinit and again on every switch, never reuses a UID or GID, and leaves
  # the password files read-only. sops-nix orders the user secrets ahead of it.
  services.userborn.enable = true;

  # passwords/root is declared by the sops aspect.
  users.users.root = {
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets."passwords/root".path;

    openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile ../../_assets/authorized_keys);
  };
}
