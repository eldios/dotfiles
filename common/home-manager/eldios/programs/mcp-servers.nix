{
  config,
  ...
}:
let
  # MCP Server definitions - single source of truth
  mcpServers = {
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

    mutx = {
      port = 3030;
      internalPort = 8000;
      dockerfile = ''
        FROM ghcr.io/mutx-net/mcp
      '';
      command = [
        "mutx-mcp"
        "--mode"
        "http"
        "--bind"
        "0.0.0.0:8000"
      ];
      env = { };
      envSecrets = { };
      volumes = [
        "/tmp/mutx:/tmp/mutx"
      ];
    };

    anytype = {
      port = 3001;
      internalPort = 8000;
      dockerfile = ''
        FROM node:22-alpine AS node
        RUN npm install -g supergateway
        FROM ghcr.io/anyproto/anytype-mcp:latest AS anytype
        FROM node:22-alpine
        RUN apk add --no-cache tini
        COPY --from=node /usr/local/lib/node_modules/supergateway /usr/local/lib/node_modules/supergateway
        RUN ln -s /usr/local/lib/node_modules/supergateway/dist/index.js /usr/local/bin/supergateway && chmod +x /usr/local/bin/supergateway
        COPY --from=anytype /app /app
        WORKDIR /app
      '';
      command = [
        "supergateway"
        "--stdio"
        "node /app/bin/cli.mjs run"
        "--port"
        "8000"
      ];
      env = {
        ANYTYPE_API_BASE_URL = "http://host.docker.internal:31009";
        OPENAPI_MCP_HEADERS = "\${ANYTYPE_HEADERS}";
      };
      envSecrets = {
        ANYTYPE_HEADERS = config.sops.placeholder."tokens/mcp/anytype_headers";
      };
      extraHosts = [
        "host.docker.internal:host-gateway"
      ];
    };
  };

  # Helper to generate docker-compose service YAML
  mkDockerService = name: cfg: ''
      ${name}:
        build:
          context: .
          dockerfile_inline: |
    ${builtins.concatStringsSep "\n" (
      map (line: "        ${line}") (
        builtins.filter (x: builtins.isString x && x != "") (builtins.split "\n" cfg.dockerfile)
      )
    )}
        command: ${builtins.toJSON cfg.command}
    ${
      if cfg.env != { } then
        ''
              environment:
          ${builtins.concatStringsSep "\n" (
            builtins.attrValues (builtins.mapAttrs (k: v: "      - ${k}=${v}") cfg.env)
          )}''
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
    ${
      if cfg ? extraHosts && cfg.extraHosts != [ ] then
        ''
              extra_hosts:
          ${builtins.concatStringsSep "\n" (map (h: "      - \"${h}\"") cfg.extraHosts)}''
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
    ${builtins.concatStringsSep "\n" (
      builtins.attrValues (builtins.mapAttrs mkDockerService mcpServers)
    )}
  '';

  # Generate .env content from all envSecrets
  allEnvSecrets = builtins.foldl' (acc: cfg: acc // (cfg.envSecrets or { })) { } (
    builtins.attrValues mcpServers
  );

  envContent = ''
    # MCP Servers Environment Variables
    # Generated by NixOS via SOPS - DO NOT EDIT MANUALLY

    # General Paths
    HOME_DIR=/home/eldios
    MCP_DATA_DIR=/home/eldios/.mcp
    KUBE_CONFIG_DIR=/home/eldios/.kube

    # Server-specific secrets
    ${builtins.concatStringsSep "\n" (
      builtins.attrValues (builtins.mapAttrs (k: v: "${k}=${toString v}") allEnvSecrets)
    )}
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
