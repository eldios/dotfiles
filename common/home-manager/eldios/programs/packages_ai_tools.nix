# AI coding assistant CLIs - all tools consolidated in one place.
{ pkgs, ... }:
{
  home.packages = [
    pkgs.claude-code # Anthropic (via claude-code-overlay flake)
    pkgs.codex       # OpenAI (via codex-cli-nix flake)
    pkgs.gemini-cli  # Google Gemini (via gemini-cli-nix flake)
    pkgs.gws         # Google Workspace CLI (via gws-cli overlay)
  ];
}
# vim: set ts=2 sw=2 et ai list nu
