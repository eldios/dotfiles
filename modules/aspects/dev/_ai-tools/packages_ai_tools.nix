# AI coding assistant CLIs - all tools consolidated in one place.
{pkgs, ...}: {
  home.packages = with pkgs; [
    antigravity-cli # Google Antigravity CLI (local fixed-output package)
    claude-code # Anthropic (via claude-code-overlay flake)
    codex # OpenAI (via codex-cli-nix flake)
    crush # Charmbracelet (via llm-agents-nix/crush overlay)
    fabric-ai # Fabric is an open-source AI CLI tool
    gws # Google Workspace CLI (via gws-cli overlay)
    multica # Multica CLI and runtime daemon (via multica overlay)
    multica-desktop # Multica desktop app (via multica overlay)
    pi # Pi coding agent (via multica overlay, from llm-agents-nix)
    ollama # CPU build, used as a client (OLLAMA_HOST); no ROCm
  ];
}
# vim: set ts=2 sw=2 et ai list nu

