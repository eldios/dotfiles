# Overlay: Charmbracelet Crush (agentic coding CLI)
#
# The upstream flake (github:numtide/llm-agents.nix) exports packages but no
# per-tool overlay. This overlay adds pkgs.crush from the flake's packages output.
{ llm-agents-nix, ... }:

self: super:
{
  crush = llm-agents-nix.packages.${super.stdenv.hostPlatform.system}.crush;
}
# vim: set ts=2 sw=2 et ai list nu
