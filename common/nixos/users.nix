{
  lib,
  pkgs,
  config,
  ...
}:
{
  users.mutableUsers = false;

  users.users.eldios = {
    shell = pkgs.zsh;

    isNormalUser = true;
    extraGroups = [
      "dialout"
      "docker"
      "input"
      "libvirt"
      "uinput"
      "video"
      "wheel"
    ];

    openssh.authorizedKeys.keys = (lib.splitString "\n" (builtins.readFile ../files/authorized_keys));
  };

  users.users.root = {
    shell = pkgs.bash;
    hashedPasswordFile = config.sops.secrets."passwords/root".path;

    openssh.authorizedKeys.keys = (lib.splitString "\n" (builtins.readFile ../files/authorized_keys));
  };
}
