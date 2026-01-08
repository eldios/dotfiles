{
  config,
  ...
}:
let
  # MCP Server definitions - single source of truth
  mcpServers = {
    homeassistant = {
      port = 3003;
      internalPort = 8000;
      dockerfile = ''
        FROM python:3.12-alpine
        RUN pip install --no-cache-dir mcp-proxy
        RUN apk add --no-cache nodejs npm
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "mcp-proxy --transport streamablehttp \${HA_HOST}/api/mcp"
        "--port"
        "8000"
      ];
      env = {
        API_ACCESS_TOKEN = "\${HA_API_TOKEN}";
      };
      envSecrets = {
        HA_HOST = config.sops.placeholder."tokens/mcp/ha_host";
        HA_API_TOKEN = config.sops.placeholder."tokens/mcp/ha_api_token";
      };
    };

    grafana = {
      port = 3002;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway @leval/mcp-grafana
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "mcp-grafana"
        "--port"
        "8000"
      ];
      env = {
        GRAFANA_URL = "\${GRAFANA_URL}";
        GRAFANA_SERVICE_ACCOUNT_TOKEN = "\${GRAFANA_TOKEN}";
      };
      envSecrets = {
        GRAFANA_URL = config.sops.placeholder."tokens/mcp/grafana_url";
        GRAFANA_TOKEN = config.sops.placeholder."tokens/mcp/grafana_token";
      };
    };

    unifi = {
      port = 3005;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y @thelord/unifi-mcp-server"
        "--port"
        "8000"
      ];
      env = {
        UNIFI_GATEWAY_IP = "\${UNIFI_GATEWAY_IP}";
        UNIFI_API_KEY = "\${UNIFI_API_KEY}";
        UNIFI_PORT = "\${UNIFI_PORT}";
        UNIFI_SITE = "\${UNIFI_SITE}";
        UNIFI_VERIFY_SSL = "\${UNIFI_VERIFY_SSL}";
      };
      envSecrets = {
        UNIFI_GATEWAY_IP = config.sops.placeholder."tokens/mcp/unifi_gateway_ip";
        UNIFI_API_KEY = config.sops.placeholder."tokens/mcp/unifi_api_key";
        UNIFI_PORT = config.sops.placeholder."tokens/mcp/unifi_api_port";
        UNIFI_SITE = config.sops.placeholder."tokens/mcp/unifi_api_site";
        UNIFI_VERIFY_SSL = config.sops.placeholder."tokens/mcp/unifi_api_verify_ssl";
      };
    };

    n8n = {
      port = 3006;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y n8n-mcp"
        "--port"
        "8000"
      ];
      env = {
        MCP_MODE = "stdio";
        LOG_LEVEL = "error";
        DISABLE_CONSOLE_OUTPUT = "true";
        N8N_API_URL = "\${N8N_API_URL}";
        N8N_API_KEY = "\${N8N_API_KEY}";
      };
      envSecrets = {
        N8N_API_URL = config.sops.placeholder."tokens/mcp/n8n_api_url";
        N8N_API_KEY = config.sops.placeholder."tokens/mcp/n8n_api_key";
      };
    };

    context7 = {
      port = 3007;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y @upstash/context7-mcp"
        "--port"
        "8000"
      ];
      env = {
        CONTEXT7_API_KEY = "\${CONTEXT7_API_KEY}";
        CLIENT_IP_ENCRYPTION_KEY = "\${CONTEXT7_ENCRYPTION_KEY}";
      };
      envSecrets = {
        CONTEXT7_API_KEY = config.sops.placeholder."tokens/mcp/context7_api_key";
        CONTEXT7_ENCRYPTION_KEY = config.sops.placeholder."tokens/mcp/context7_encryption_key";
      };
    };

    dockerhub = {
      port = 3009;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN apk add --no-cache git
        RUN npm install -g supergateway
        RUN git clone --depth 1 https://github.com/docker/hub-mcp.git /app/hub-mcp && \
            cd /app/hub-mcp && npm install && npm run build
        WORKDIR /app/hub-mcp
      '';
      command = [
        "supergateway"
        "--stdio"
        "node /app/hub-mcp/dist/index.js --transport=stdio"
        "--port"
        "8000"
      ];
      env = {
        HUB_PAT_TOKEN = "\${DOCKERHUB_TOKEN}";
      };
      envSecrets = {
        DOCKERHUB_TOKEN = config.sops.placeholder."tokens/mcp/dockerhub_token";
      };
    };

    memory = {
      port = 3010;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y @modelcontextprotocol/server-memory"
        "--port"
        "8000"
      ];
      env = {
        MEMORY_FILE_PATH = "/data/memory";
      };
      envSecrets = { };
      volumes = [
        "\${MCP_DATA_DIR}/memory:/data"
      ];
    };

    github = {
      port = 3011;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine AS node
        RUN npm install -g supergateway
        FROM ghcr.io/github/github-mcp-server AS github
        FROM alpine:3.20
        RUN apk add --no-cache nodejs npm
        COPY --from=node /usr/local/lib/node_modules/supergateway /usr/local/lib/node_modules/supergateway
        RUN ln -s /usr/local/lib/node_modules/supergateway/dist/index.js /usr/local/bin/supergateway && chmod +x /usr/local/bin/supergateway
        COPY --from=github /server/github-mcp-server /usr/local/bin/github-mcp-server
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "/usr/local/bin/github-mcp-server stdio"
        "--port"
        "8000"
      ];
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_TOKEN}";
      };
      envSecrets = {
        GITHUB_TOKEN = config.sops.placeholder."tokens/mcp/github_token";
      };
    };

    filesystem = {
      port = 3015;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y @modelcontextprotocol/server-filesystem /mnt/home"
        "--port"
        "8000"
      ];
      env = { };
      envSecrets = { };
      volumes = [
        "\${HOME_DIR}:/mnt/home"
      ];
    };

    kagisearch = {
      port = 3018;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y kagi-mcp"
        "--port"
        "8000"
      ];
      env = {
        KAGI_SUMMARIZER_ENGINE = "\${KAGI_ENGINE}";
        KAGI_API_KEY = "\${KAGI_API_KEY}";
      };
      envSecrets = {
        KAGI_ENGINE = config.sops.placeholder."tokens/mcp/kagi_engine";
        KAGI_API_KEY = config.sops.placeholder."tokens/mcp/kagi_api_key";
      };
    };

    kubernetes = {
      port = 3019;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y kubernetes-mcp-server"
        "--port"
        "8000"
      ];
      env = { };
      envSecrets = { };
      volumes = [
        "\${KUBE_CONFIG_DIR}:/root/.kube:ro"
      ];
    };

    opentofu = {
      port = 3023;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y @opentofu/opentofu-mcp-server"
        "--port"
        "8000"
      ];
      env = { };
      envSecrets = { };
    };

    playwright = {
      port = 3024;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-bookworm-slim
        RUN npm install -g supergateway
        RUN npx playwright install chromium --with-deps
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "npx -y @playwright/mcp@latest"
        "--port"
        "8000"
      ];
      env = { };
      envSecrets = { };
    };

    linera-slack = {
      port = 3025;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine AS node
        RUN npm install -g supergateway
        FROM mcp/slack AS slack
        FROM node:22-alpine
        COPY --from=node /usr/local/lib/node_modules/supergateway /usr/local/lib/node_modules/supergateway
        RUN ln -s /usr/local/lib/node_modules/supergateway/dist/index.js /usr/local/bin/supergateway && chmod +x /usr/local/bin/supergateway
        COPY --from=slack /app /app
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "node /app/dist/index.js"
        "--port"
        "8000"
      ];
      env = {
        SLACK_BOT_TOKEN = "\${LINERA_SLACK_BOT_TOKEN}";
        SLACK_TEAM_ID = "\${LINERA_SLACK_TEAM_ID}";
      };
      envSecrets = {
        LINERA_SLACK_BOT_TOKEN = config.sops.placeholder."tokens/mcp/linera_slack_bot_token";
        LINERA_SLACK_TEAM_ID = config.sops.placeholder."tokens/mcp/linera_slack_team_id";
      };
    };
  };

  # Helper to generate docker-compose service YAML
  mkDockerService = name: cfg: ''
    ${name}:
      build:
        context: .
        dockerfile_inline: |
  ${builtins.concatStringsSep "\n" (map (line: "        ${line}") (builtins.filter (x: builtins.isString x && x != "") (builtins.split "\n" cfg.dockerfile)))}
      command: ${builtins.toJSON cfg.command}
  ${
    if cfg.env != { } then
      ''
            environment:
        ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (k: v: "      - ${k}=${v}") cfg.env))}''
    else
      ""
  }
  ${
    if cfg ? volumes && cfg.volumes != [ ] then
      ''
            volumes:
        ${builtins.concatStringsSep "\n" (map (v: "      - ${v}") cfg.volumes)}''
    else
      ""
  }
      ports:
        - "${toString cfg.port}:${toString cfg.internalPort}"
      restart: unless-stopped
  '';

  # Generate complete docker-compose.yml content
  dockerComposeContent = ''
    # MCP Servers - Persistent via Supergateway SSE wrapper
    # Generated by NixOS - DO NOT EDIT MANUALLY
    # Usage: docker-compose up -d
    # Claude/Gemini/nvim connect via SSE at http://localhost:PORT/sse

    services:
    ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs mkDockerService mcpServers))}
  '';

  # Generate .env content from all envSecrets
  allEnvSecrets = builtins.foldl' (acc: cfg: acc // (cfg.envSecrets or { })) { } (builtins.attrValues mcpServers);

  envContent = ''
    # MCP Servers Environment Variables
    # Generated by NixOS via SOPS - DO NOT EDIT MANUALLY

    # General Paths
    HOME_DIR=/home/eldios
    MCP_DATA_DIR=/home/eldios/.mcp
    KUBE_CONFIG_DIR=/home/eldios/.kube

    # Server-specific secrets
    ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (k: v: "${k}=${toString v}") allEnvSecrets))}
  '';

  # Generate mcphub servers.json for nvim
  mcphubServers = builtins.mapAttrs (name: cfg: {
    url = "http://localhost:${toString cfg.port}/sse";
  }) mcpServers;

  mcphubContent = builtins.toJSON { mcpServers = mcphubServers; };

  # Generate Gemini CLI settings.json
  geminiSettings = {
    mcpServers = mcphubServers;
    security = {
      auth = {
        selectedType = "oauth-personal";
      };
    };
    ui = {
      showMemoryUsage = true;
      showLineNumbers = true;
      theme = "Default";
    };
    general = {
      disableAutoUpdate = true;
      vimMode = true;
      previewFeatures = true;
    };
    tools = {
      useRipgrep = true;
    };
  };

  geminiSettingsContent = builtins.toJSON geminiSettings;

in
{
  # Generate docker-compose.yml
  home.file.".mcp/docker-compose.yml" = {
    text = dockerComposeContent;
  };

  # Generate .env via SOPS template
  sops.templates.".mcp/.env" = {
    content = envContent;
    path = "/home/eldios/.mcp/.env";
    mode = "0600";
  };

  # Generate mcphub servers.json for nvim
  xdg.configFile."mcphub/servers.json" = {
    text = mcphubContent;
  };

  # Generate Gemini CLI settings.json
  home.file.".gemini/settings.json" = {
    text = geminiSettingsContent;
  };

  # Ensure .mcp directory exists with proper permissions
  home.file.".mcp/.keep" = {
    text = "";
  };
}
# vim: set ts=2 sw=2 et ai list nu
