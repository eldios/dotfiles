# Claude Code - Anthropic's AI coding assistant CLI.
{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    claude-code # AI coding assistant from Anthropic
  ];
}
# vim: set ts=2 sw=2 et ai list nu
