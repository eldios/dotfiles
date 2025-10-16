{ inputs, config, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  sops = {
    secrets = {
      "passwords/wotah/eldios" = {
        sopsFile = "${secretspath}/wotah.yaml";
        neededForUsers = true;
      };
    };
  };

  users.users.eldios = {
    hashedPasswordFile = config.sops.secrets."passwords/wotah/eldios".path;
  };
}

# vim: set ts=2 sw=2 et ai list nu */
