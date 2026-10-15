# AI coding assistant CLIs - all tools consolidated in one place.
{pkgs, ...}: {
  home.packages = with pkgs; [
    claude-code # Anthropic (via claude-code-overlay flake)
    codex # OpenAI (via codex-cli-nix flake)
    crush # Charmbracelet (via llm-agents-nix/crush overlay)
    fabric-ai # Fabric is an open-source AI CLI tool
    gws # Google Workspace CLI (via gws-cli overlay)
    multica # Multica CLI and runtime daemon (via multica overlay)
    multica-desktop # Multica desktop app (via multica overlay)
    omnigent # Omnigent CLI, uv-run at a pinned version (via omnigent overlay)
    opencode # OpenCode (via opencode-nix flake)
    pi # Pi coding agent (via multica overlay, from llm-agents-nix)
    ollama # CPU build, used as a client (OLLAMA_HOST); no ROCm
  ];
}
# vim: set ts=2 sw=2 et ai list nu

