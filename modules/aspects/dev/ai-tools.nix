# AI coding agents and the MCP servers they talk to. The MCP configuration
# stands on its own as den.aspects.ai-tools.mcp-servers, for hosts that
# carry the agent configuration without the agent CLIs; the secrets it
# renders are declared by the user's sops module, which shares the same
# Home Manager evaluation.
{den, ...}: {
  den.aspects.ai-tools = {
    includes = [den.aspects.ai-tools.mcp-servers];

    homeManager.imports = [./_ai-tools/packages_ai_tools.nix];

    provides.mcp-servers = {
      homeManager.imports = [./_ai-tools/mcp-servers.nix];
    };
  };
}
