# Gemini CLI - Google's AI coding assistant CLI.
{ pkgs, ... }:
{
  home.packages = [
    pkgs.gemini-cli # AI coding assistant from Google (via gemini-cli-nix flake)
  ];
}
# vim: set ts=2 sw=2 et ai list nu
