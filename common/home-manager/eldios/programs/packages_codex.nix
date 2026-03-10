# Codex CLI - OpenAI's AI coding assistant CLI.
{ pkgs, ... }:
{
  home.packages = [
    pkgs.codex # AI coding assistant from OpenAI (via codex-cli-nix flake)
  ];
}
# vim: set ts=2 sw=2 et ai list nu
