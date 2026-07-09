{ inputs, config, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  sops = {
    secrets = {
      "passwords/lele8845ace/eldios" = {
        sopsFile = "${secretspath}/lele8845ace.yaml";
        neededForUsers = true;
      };
    };
  };

  users.groups.i2c.members = [ "eldios" ];
  users.users.eldios = {
    hashedPasswordFile = config.sops.secrets."passwords/lele8845ace/eldios".path;

    extraGroups = [
      "networkmanager" # manage NM connections (ProtonVPN kill switch via polkit)
      "input" # needed by xRemap
      "uinput" # needed by xRemap
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
