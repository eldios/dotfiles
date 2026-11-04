# AI coding agents and the MCP servers they talk to. The MCP configuration
# stands on its own as den.aspects.ai-tools.mcp-servers, for hosts that
# carry the agent configuration without the agent CLIs; the secrets it
# renders are declared by the user's sops module, which shares the same
# Home Manager evaluation. The Multica desktop app is opt-in per host, as
# den.aspects.ai-tools.multica-desktop.
{den, ...}: {
  den.aspects.ai-tools = {
    includes = [den.aspects.ai-tools.mcp-servers];

    homeManager.imports = [./_ai-tools/packages_ai_tools.nix];

    provides.mcp-servers = {
      homeManager.imports = [./_ai-tools/mcp-servers.nix];
    };

    provides.multica-desktop = {
      homeManager = {
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.multica-desktop];
        # ai.vpn resolves to the tailnet address from any network; ai.casa only
        # answers on the LAN. Without this file the app targets the hosted cloud.
        home.file.".multica/desktop.json" = {
          force = true;
          text = builtins.toJSON {
            schemaVersion = 1;
            apiUrl = "https://ai-vpn.example.invalid";
          };
        };
        # force replaces a file Home Manager did not write: keep a copy of it.
        home.activation.backupMulticaDesktopConfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
          f="$HOME/.multica/desktop.json"
          if [ -e "$f" ] && [ ! -L "$f" ]; then
            run cp -a "$f" "$f.bak-$(date +%Y%m%d-%H%M%S)"
          fi
        '';
      };
    };
  };
}
