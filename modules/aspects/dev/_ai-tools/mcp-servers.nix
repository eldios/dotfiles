{config, ...}: let
  hub = "https://mcp.vpn.lele.rip";

  # Bearers of the MCP hub on mininixos and of the local Anytype gateway,
  # by the variable name the clients read them from.
  mcpTokens = {
    MCP_HUB_TOKEN = "tokens/mcp/hub_token";
    MCP_GITHUB_TOKEN = "tokens/mcp/hub_github_token";
    MCP_RIFFADO_TOKEN = "tokens/mcp/hub_riffado_token";
    MCP_PLAUD_TOKEN = "tokens/mcp/hub_plaud_token";
    ANYTYPE_MCP_TOKEN = "tokens/mcp/anytype_gateway_token";
  };

  envLines = prefix:
    builtins.concatStringsSep "" (
      builtins.attrValues (
        builtins.mapAttrs (var: secret: "${prefix}${var}=${config.sops.placeholder.${secret}}\n") mcpTokens
      )
    );

  # The hub serves each server at <hub>/<name>/mcp behind its own bearer.
  # Context7 and Kagi share one; Riffado is the default for recordings,
  # plaud is the Plaud cloud.
  hubServers = {
    context7 = "MCP_HUB_TOKEN";
    github = "MCP_GITHUB_TOKEN";
    kagisearch = "MCP_HUB_TOKEN";
    riffado = "MCP_RIFFADO_TOKEN";
    plaud = "MCP_PLAUD_TOKEN";
  };

  # mcphub.nvim expands ${VAR} in headers from the environment.
  mcphubServers =
    builtins.mapAttrs (name: var: {
      url = "${hub}/${name}/mcp";
      headers.Authorization = "Bearer \${${var}}";
    })
    hubServers
    // {
      anytype = {
        url = "http://localhost:3001/mcp";
        headers.Authorization = "Bearer \${ANYTYPE_MCP_TOKEN}";
      };
      # A hostname of the private network, so it lives in sops.
      browser.url = config.sops.placeholder."tokens/mcp/browser_url";
    };
in {
  # mcphub servers.json for nvim; a sops template, since the browser URL is
  # secret.
  sops.templates."mcphub/servers.json" = {
    content = builtins.toJSON {mcpServers = mcphubServers;};
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

  # The MCP bearers, read the same way by Claude and Codex: exported by zsh,
  # and given to the Multica daemon's agents through a drop-in.
  sops.templates."agents/mcp.env" = {
    content = envLines "export ";
    path = "/home/eldios/.config/agents/mcp.env";
    mode = "0600";
  };

  sops.templates."agents/mcp.systemd.env" = {
    content = envLines "";
    path = "/home/eldios/.config/agents/mcp.systemd.env";
    mode = "0600";
  };

  xdg.configFile."systemd/user/multica-daemon.service.d/mcp-env.conf".text = ''
    [Service]
    EnvironmentFile=${config.sops.templates."agents/mcp.systemd.env".path}
  '';

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
}
# vim: set ts=2 sw=2 et ai list nu

