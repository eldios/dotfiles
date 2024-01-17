{ pkgs, ... }:
{

  users.users.eldios = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "video"
    ]; # Enable ‘sudo’ for the user.

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdQy58cEJ3mzNn1mhX89LbTqBKE3pA0NpIQWgqiRpF1 lele@mac13M1"
    ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdQy58cEJ3mzNn1mhX89LbTqBKE3pA0NpIQWgqiRpF1 lele@mac13M1"
    ];
  };
}

/* vim: set ts=2 sw=2 et ai list nu */
