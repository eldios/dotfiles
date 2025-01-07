{ inputs, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets.yaml";
    validateSopsFiles = true;

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
