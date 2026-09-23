# AI coding assistant CLIs - all tools consolidated in one place.
{pkgs, ...}: {
  home.packages = with pkgs; [
    claude-code # Anthropic (via claude-code-overlay flake)
    codex # OpenAI (via codex-cli-nix flake)
    crush # Charmbracelet (via llm-agents-nix/crush overlay)
    fabric-ai # Fabric is an open-source AI CLI tool
    gws # Google Workspace CLI (via gws-cli overlay)
    opencode # OpenCode (via opencode-nix flake)
    ollama # CPU build, used as a client (OLLAMA_HOST); no ROCm
  ];
}
# vim: set ts=2 sw=2 et ai list nu

