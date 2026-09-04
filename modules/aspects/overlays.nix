# Every package overlay, applied on every host. Overlays are lazy: an entry
# costs nothing until a host references the package it defines, so one list
# serves desktops and the headless server alike.
{inputs, ...}: {
  den.aspects.overlays.nixos.nixpkgs.overlays = [
    (import ./_overlays/unstable-packages.nix {inherit (inputs) nixpkgs-unstable;})
    (import ./_overlays/antigravity-cli.nix)
    inputs.claude-code-overlay.overlays.default
    inputs.codex-cli-nix.overlays.default
    inputs.opencode-nix.overlays.default
    inputs.herdr.overlays.default
    inputs.riso.overlays.default
    (import ./_overlays/crush.nix {inherit (inputs) llm-agents-nix;})
    (import ./_overlays/gws-cli.nix {inherit (inputs) gws-cli;})
    (import ./_overlays/zen-browser.nix {inherit (inputs) zen-browser;})
    (import ./_overlays/ratspeak.nix {inherit (inputs) nix-ratspeak;})
    (import ./_overlays/vm-curator.nix {inherit (inputs) vm-curator;})
    (import ./_overlays/gitbutler.nix)
    (import ./_overlays/qbz.nix)
    (import ./_overlays/pi-coding-agent.nix)
    (import ./_overlays/buzz-desktop.nix)
  ];
}
