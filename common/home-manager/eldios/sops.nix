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
      "tokens/openrouter/neovim/key" = { };
      "tokens/openrouter/aider/key" = { };
      "tokens/gemini/key" = { };
      "tokens/ollama/key" = { };
      "tokens/ollama/url" = { };
      "tokens/litellm/neovim/key" = { };
      "tokens/litellm/neovim/url" = { };
      "tokens/litellm/aider/key" = { };
      "tokens/litellm/aider/url" = { };
      "tokens/kagi/key" = { };
      "tokens/github/nix" = { };
      "keys/anytype/id" = { };
      "keys/anytype/networkId" = { };
      "keys/anytype/host" = { };
      "keys/anytype/peerId/node-1" = { };
      "keys/anytype/peerId/node-2" = { };
      "keys/anytype/peerId/node-3" = { };
      "keys/anytype/peerId/coordinator" = { };
      "keys/anytype/peerId/filenode" = { };
      "keys/anytype/peerId/consensusnode" = { };

      # MCP Server tokens
      "tokens/mcp/context7_api_key" = { };
      "tokens/mcp/context7_encryption_key" = { };
      "tokens/mcp/dockerhub_token" = { };
      "tokens/mcp/github_token" = { };
      "tokens/mcp/grafana_token" = { };
      "tokens/mcp/grafana_url" = { };
      "tokens/mcp/ha_api_token" = { };
      "tokens/mcp/ha_host" = { };
      "tokens/mcp/kagi_api_key" = { };
      "tokens/mcp/kagi_engine" = { };
      "tokens/mcp/linera_slack_bot_token" = { };
      "tokens/mcp/linera_slack_team_id" = { };
      "tokens/mcp/n8n_api_key" = { };
      "tokens/mcp/n8n_api_url" = { };
      "tokens/mcp/unifi_api_key" = { };
      "tokens/mcp/unifi_api_port" = { };
      "tokens/mcp/unifi_api_site" = { };
      "tokens/mcp/unifi_api_verify_ssl" = { };
      "tokens/mcp/unifi_gateway_ip" = { };

    };

    templates = {
      "aider.conf.yml" = {
        content = ''
          dark-mode: true

          openai-api-key: "${config.sops.placeholder."tokens/litellm/aider/key"}"
          openai-api-base: "${config.sops.placeholder."tokens/litellm/aider/url"}"
        '';
        path = "/home/eldios/.aider.conf.yml";
      };
      "anytype.conf.yml" = {
        content = ''
          id: ${config.sops.placeholder."keys/anytype/id"}
          networkId: ${config.sops.placeholder."keys/anytype/networkId"}
          nodes:
            - addresses:
                - any-sync-node-1:1001
                - quic://any-sync-node-1:1011
                - ${config.sops.placeholder."keys/anytype/host"}:1001
                - quic://${config.sops.placeholder."keys/anytype/host"}:1011
              peerId: ${config.sops.placeholder."keys/anytype/peerId/node-1"}
              types:
                - tree
            - addresses:
                - any-sync-node-2:1002
                - quic://any-sync-node-2:1012
                - ${config.sops.placeholder."keys/anytype/host"}:1002
                - quic://${config.sops.placeholder."keys/anytype/host"}:1012
              peerId: ${config.sops.placeholder."keys/anytype/peerId/node-2"}
              types:
                - tree
            - addresses:
                - any-sync-node-3:1003
                - quic://any-sync-node-3:1013
                - ${config.sops.placeholder."keys/anytype/host"}:1003
                - quic://${config.sops.placeholder."keys/anytype/host"}:1013
              peerId: ${config.sops.placeholder."keys/anytype/peerId/node-3"}
              types:
                - tree
            - addresses:
                - any-sync-coordinator:1004
                - quic://any-sync-coordinator:1014
                - ${config.sops.placeholder."keys/anytype/host"}:1004
                - quic://${config.sops.placeholder."keys/anytype/host"}:1014
              peerId: ${config.sops.placeholder."keys/anytype/peerId/coordinator"}
              types:
                - coordinator
            - addresses:
                - any-sync-filenode:1005
                - quic://any-sync-filenode:1015
                - ${config.sops.placeholder."keys/anytype/host"}:1005
                - quic://${config.sops.placeholder."keys/anytype/host"}:1015
              peerId: ${config.sops.placeholder."keys/anytype/peerId/filenode"}
              types:
                - file
            - addresses:
                - any-sync-consensusnode:1006
                - quic://any-sync-consensusnode:1016
                - ${config.sops.placeholder."keys/anytype/host"}:1006
                - quic://${config.sops.placeholder."keys/anytype/host"}:1016
              peerId: ${config.sops.placeholder."keys/anytype/peerId/consensusnode"}
              types:
                - consensus
        '';
        path = "/home/eldios/.config/anytype.conf.yml";
      };
    };

  };

}
