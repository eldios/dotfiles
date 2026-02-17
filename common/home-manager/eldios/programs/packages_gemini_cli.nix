# Gemini CLI - Google's AI coding assistant CLI.
{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    gemini-cli # AI coding assistant from Google
  ];
}
# vim: set ts=2 sw=2 et ai list nu
