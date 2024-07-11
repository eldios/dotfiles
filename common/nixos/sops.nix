{ inputs, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = true;

    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];

      keyFile = "/etc/sops/key.txt";

      generateKey = true;
    };

    secrets = {
      "passwords/lele9iyoga/eldios" = { };
      "passwords/lele9iyoga/root" = { };

      "keys/ssh/eldios/lele9iyoga/public" = { };
      "keys/ssh/eldios/lele9iyoga/private" = { };

      "tokens/kubernetes/casa" = { };
    };
  };
}
