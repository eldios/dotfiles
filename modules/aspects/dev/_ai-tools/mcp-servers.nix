{config, ...}: let
  streamableHttpPath = "/mcp";
  # SSE output from a single stdio MCP process crashes when multiple clients
  # connect concurrently. Use stateful Streamable HTTP for stdio MCP servers
  # shared by Codex, Claude, nvim, and other clients.
  streamableHttpArgs = [
    "--outputTransport"
    "streamableHttp"
    "--streamableHttpPath"
    streamableHttpPath
    "--stateful"
    "--sessionTimeout"
    "600000"
  ];

  # MCP Server definitions - single source of truth
  mcpServers = {
    context7 = {
      port = 3007;
      internalPort = 8000;
      mcpPath = streamableHttpPath;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command =
        [
          "supergateway"
          "--stdio"
          "npx -y @upstash/context7-mcp"
          "--port"
          "8000"
        ]
        ++ streamableHttpArgs;
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
      mcpPath = streamableHttpPath;
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
      command =
        [
          "supergateway"
          "--stdio"
          "/usr/local/bin/github-mcp-server stdio"
          "--port"
          "8000"
        ]
        ++ streamableHttpArgs;
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
      mcpPath = streamableHttpPath;
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command =
        [
          "supergateway"
          "--stdio"
          "npx -y kagi-mcp"
          "--port"
          "8000"
        ]
        ++ streamableHttpArgs;
      env = {
        KAGI_SUMMARIZER_ENGINE = "\${KAGI_ENGINE}";
        KAGI_API_KEY = "\${KAGI_API_KEY}";
      };
      envSecrets = {
        KAGI_ENGINE = config.sops.placeholder."tokens/mcp/kagi_engine";
        KAGI_API_KEY = config.sops.placeholder."tokens/mcp/kagi_api_key";
      };
    };

    plaud = {
      port = 3050;
      internalPort = 8000;
      mcpPath = streamableHttpPath;
      refs = [
        "https://support.plaud.ai/hc/en-us/articles/57751078986265-Plaud-MCP"
        "https://docs.plaud.ai/documentation/plaud_app/mcp"
      ];
      dockerfile = ''
        FROM node:22-alpine
        RUN npm install -g supergateway
        WORKDIR /app
      '';
      command =
        [
          "supergateway"
          "--stdio"
          "npx -y @plaud-ai/mcp@latest"
          "--port"
          "8000"
        ]
        ++ streamableHttpArgs;
      env = {};
      envSecrets = {};
      volumes = [
        "\${HOME_DIR}/.plaud:/root/.plaud"
      ];
    };
  };

  # Optional YAML comment block emitted before a service (for upstream docs links)
  mkRefsComment = cfg:
    if cfg ? refs && cfg.refs != []
    then (builtins.concatStringsSep "\n" (map (u: "  # ${u}") cfg.refs)) + "\n"
    else "";

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
      if cfg ? user && cfg.user != ""
      then "    user: \"${cfg.user}\""
      else ""
    }
    ${
      if cfg.env != {}
      then ''
            environment:
        ${builtins.concatStringsSep "\n" (
          builtins.attrValues (builtins.mapAttrs (k: v: "      - ${k}=${v}") cfg.env)
        )}''
      else ""
    }
    ${
      if cfg ? volumes && cfg.volumes != []
      then ''
            volumes:
        ${builtins.concatStringsSep "\n" (map (v: "      - ${v}") cfg.volumes)}''
      else ""
    }
    ${
      if cfg ? networkMode && cfg.networkMode != ""
      then "    network_mode: \"${cfg.networkMode}\""
      else ''
        ${
          if cfg ? extraHosts && cfg.extraHosts != []
          then ''
              extra_hosts:
            ${builtins.concatStringsSep "\n" (map (h: "      - \"${h}\"") cfg.extraHosts)}''
          else ""
        }
            ports:
              - "127.0.0.1:${toString cfg.port}:${toString cfg.internalPort}"''
    }
    ${
      if cfg ? healthcheck
      then
        "    healthcheck:\n"
        + "      test: ${builtins.toJSON cfg.healthcheck.test}\n"
        + "      interval: ${cfg.healthcheck.interval}\n"
        + "      timeout: ${cfg.healthcheck.timeout}\n"
        + "      retries: ${toString cfg.healthcheck.retries}\n"
        + "      start_period: ${cfg.healthcheck.start_period}"
      else ""
    }
        restart: unless-stopped
  '';

  # Generate complete docker-compose.yml content
  dockerComposeContent = ''
    # MCP Servers - Persistent via Supergateway wrapper
    # Generated by NixOS - DO NOT EDIT MANUALLY
    # Usage: docker-compose up -d
    # Claude/Gemini/nvim connect via each generated MCP server URL

    services:
    ${builtins.concatStringsSep "\n" (
      builtins.attrValues (
        builtins.mapAttrs (name: cfg: mkRefsComment cfg + mkDockerService name cfg) mcpServers
      )
    )}
  '';

  # Generate .env content from all envSecrets
  allEnvSecrets = builtins.foldl' (acc: cfg: acc // (cfg.envSecrets or {})) {} (
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

  # MCP servers that run elsewhere (homelab stacks), reached by URL only. The
  # URLs are hostnames of the private network, so they live in sops.
  remoteMcpServers = {
    browser = {
      url = config.sops.placeholder."tokens/mcp/browser_url";
    };
  };

  # Generate mcphub servers.json for nvim
  mcphubServers =
    builtins.mapAttrs (name: cfg: {
      url = "http://localhost:${toString cfg.port}${cfg.mcpPath or "/sse"}";
    })
    mcpServers
    // remoteMcpServers;

  mcphubContent = builtins.toJSON {mcpServers = mcphubServers;};
in {
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

  # Generate mcphub servers.json for nvim; a sops template, since the remote
  # entries carry secret URLs.
  sops.templates."mcphub/servers.json" = {
    content = mcphubContent;
    path = "/home/eldios/.config/mcphub/servers.json";
    mode = "0600";
  };

  # Bearer token for the Hindsight MCP server (shared agent memory). Claude,
  # Codex and Pi read HINDSIGHT_TOKEN from the environment through their own
  # MCP config, so interactive shells, and the agents they start, export it.
  sops.templates."agents/hindsight.env" = {
    content = "export HINDSIGHT_TOKEN=${config.sops.placeholder."tokens/mcp/hindsight_token"}\n";
    path = "/home/eldios/.config/agents/hindsight.env";
    mode = "0600";
  };

  # Bearers of the MCP hub on mininixos (mcp.vpn.lele.rip) and of the local
  # Anytype gateway, read the same way by Claude and Codex.
  sops.templates."agents/mcp.env" = {
    content = ''
      export MCP_HUB_TOKEN=${config.sops.placeholder."tokens/mcp/hub_token"}
      export MCP_GITHUB_TOKEN=${config.sops.placeholder."tokens/mcp/hub_github_token"}
      export MCP_RIFFADO_TOKEN=${config.sops.placeholder."tokens/mcp/hub_riffado_token"}
      export MCP_PLAUD_TOKEN=${config.sops.placeholder."tokens/mcp/hub_plaud_token"}
      export ANYTYPE_MCP_TOKEN=${config.sops.placeholder."tokens/mcp/anytype_gateway_token"}
    '';
    path = "/home/eldios/.config/agents/mcp.env";
    mode = "0600";
  };

  # Environment of the Anytype MCP gateway, a compose project kept outside
  # Nix next to the desktop app it talks to.
  sops.templates."agents/anytype-mcp.env" = {
    content = ''
      OPENAPI_MCP_HEADERS=${config.sops.placeholder."tokens/mcp/anytype_headers"}
      SUPERGATEWAY_API_KEY=${config.sops.placeholder."tokens/mcp/anytype_gateway_token"}
    '';
    path = "/home/eldios/.config/agents/anytype-mcp.env";
    mode = "0600";
  };

  programs.zsh.initContent = ''
    for f in "$HOME/.config/agents/hindsight.env" "$HOME/.config/agents/mcp.env"; do
      if [[ -r "$f" ]]; then
        source "$f"
      fi
    done
  '';

  # Ensure .mcp directory exists with proper permissions
  home.file.".mcp/.keep" = {
    text = "";
  };
}
# vim: set ts=2 sw=2 et ai list nu

