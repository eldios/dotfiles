{ inputs, config, ... }:
let
  secretspath = builtins.toString inputs.secrets;
in
{
  sops = {
    validateSopsFiles = true;

    defaultSopsFile = "${secretspath}/secrets.yaml";
    # workaround to have home-manager work with sops
    #defaultSymlinkPath = "/run/user/${main_user_id}/secrets";
    #defaultSecretsMountPoint = "/run/user/${main_user_id}/secrets.d";

    gnupg.sshKeyPaths = [ ];

    age = {
      keyFile = "/etc/sops/key.txt";

      generateKey = false;
    };

    secrets = {
      "tokens/anthropic/key" = { };
      "tokens/openai/key" = { };
      "tokens/openrouter/aider/key" = { };
      "tokens/gemini/key" = { };
      "tokens/ollama/key" = { };
      "tokens/ollama/url" = { };
      "tokens/litellm/neovim/key" = { };
      "tokens/litellm/neovim/url" = { };
      "tokens/litellm/aider/key" = { };
      "tokens/litellm/aider/url" = { };
      "tokens/kagi/key" = { };
    };

    templates = {
      "aider.conf.yml" = {
        content = ''
          dark_mode: true

          openai-api-key: "${config.sops.placeholder."tokens/litellm/aider/key"}"
          openai-api-base: "${config.sops.placeholder."tokens/litellm/aider/url"}"
        '';
        path = "/home/eldios/.aider.conf.yml";
      };
    };

  };

}
