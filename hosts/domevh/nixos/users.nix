{
  inputs,
  config,
  ...
}:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  sops.secrets = {
    "passwords/domevh/eldios" = {
      sopsFile = "${secretspath}/domevh.yaml";
      neededForUsers = true;
    };
  };

  users.users.eldios = {
    hashedPasswordFile = config.sops.secrets."passwords/domevh/eldios".path;
  };
}

# vim: set ts=2 sw=2 et ai list nu
