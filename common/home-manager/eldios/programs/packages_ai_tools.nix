# AI coding assistant CLIs - all tools consolidated in one place.
{ pkgs, ... }:
{
  home.packages = [
    pkgs.claude-code # Anthropic (via claude-code-overlay flake)
    pkgs.codex       # OpenAI (via codex-cli-nix flake)
    pkgs.crush       # Charmbracelet (via llm-agents-nix/crush overlay)
    pkgs.gemini-cli  # Google Gemini (via gemini-cli-nix flake)
    pkgs.gws         # Google Workspace CLI (via gws-cli overlay)
    pkgs.opencode    # OpenCode (via opencode-nix flake)
  ];
}
# vim: set ts=2 sw=2 et ai list nu
