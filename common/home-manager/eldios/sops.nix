{ inputs, ... }:
let
  main_user_id = 1000; # run `id` to find it

  secretspath = builtins.toString inputs.secrets;
in
{
  sops = {
    validateSopsFiles = true;

    defaultSopsFile = "${secretspath}/secrets.yaml";
    # workaround to have home-manager work with sops
    defaultSymlinkPath = "/run/user/${main_user_id}/secrets";
    defaultSecretsMountPoint = "/run/user/${main_user_id}/secrets.d";

    gnupg.sshKeyPaths = [ ];

    age = {
      sshKeyPaths = [
        "/etc/ssh/ssh_host_ed25519_key"
      ];

      keyFile = "/etc/sops/key.txt";

      generateKey = false;
    };

    secrets = {
      "tokens/anthropic/key" = { };
      "tokens/openai/key" = { };
      "tokens/gemini/key" = { };
      "tokens/ollama/key" = { };
      "tokens/ollama/url" = { };
    };
  };

}
