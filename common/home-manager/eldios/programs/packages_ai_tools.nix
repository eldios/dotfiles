# AI coding assistant CLIs - all tools consolidated in one place.
{pkgs, ...}: {
  home.packages = [
    pkgs.antigravity-cli # Google Antigravity CLI (local fixed-output package)
    pkgs.claude-code # Anthropic (via claude-code-overlay flake)
    pkgs.codex # OpenAI (via codex-cli-nix flake)
    pkgs.crush # Charmbracelet (via llm-agents-nix/crush overlay)
    pkgs.gws # Google Workspace CLI (via gws-cli overlay)
    pkgs.herdr # agent multiplexer for AI CLIs (via herdr flake overlay)
    pkgs.opencode # OpenCode (via opencode-nix flake)
    pkgs.pi-coding-agent # Pi (via local overlay from npm registry)
    pkgs.ollama # CPU build, used as a client (OLLAMA_HOST -> mininixos over Tailscale); no ROCm
  ];
}
# vim: set ts=2 sw=2 et ai list nu

