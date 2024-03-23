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
    hashedPassword = "$y$j9T$bVRCi17N5F346daV74FnV1$ECDE6j19KXmVBTFDZYDSyYJJ2YuBqh2Jpjlr76L9c02";
  };

  users.users.root = {
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = (lib.splitString "\n" (builtins.readFile ../files/authorized_keys)) ;
    hashedPassword = "$y$j9T$bVRCi17N5F346daV74FnV1$ECDE6j19KXmVBTFDZYDSyYJJ2YuBqh2Jpjlr76L9c02";
  };
}
