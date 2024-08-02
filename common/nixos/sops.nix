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
      "tokens/kubernetes/casa" = { };

      "passwords/root" = { };
      "passwords/lele9iyoga/eldios" = {
        sopsFile = "${secretspath}/lele9iyoga.yaml";
      };

      "keys/ssh/eldios/lele9iyoga/public" = {
        sopsFile = "${secretspath}/lele9iyoga.yaml";
      };
      "keys/ssh/eldios/lele9iyoga/private" = {
        sopsFile = "${secretspath}/lele9iyoga.yaml";
      };
    };
  };
}
