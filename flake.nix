{
  description = "Lele's nix conf - for macOS and nixOS";

  # Every module under ./modules is a den module, auto-imported by
  # import-tree; plain NixOS and Home Manager modules live under `_` paths,
  # which import-tree skips. Hosts, users and features are declared there.
  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [(inputs.import-tree ./modules)];
      specialArgs = {inherit inputs;};
    }).config.flake;

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Aspect-oriented configuration framework and its module loader.
    den.url = "github:denful/den";
    import-tree.url = "github:denful/import-tree";

    # additional utils
    nixos-hardware.url = "github:nixos/nixos-hardware";
    xremap.url = "github:xremap/nix-flake";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/eldios/secrets.git?ref=main&shallow=1";
      flake = false;
    };

    mpc-hub = {
      url = "github:ravitemer/mcp-hub";
    };

    # Launcher stack for the hosts still on the pre-Quickshell desktop.
    # Drop both once every host imports omarchy-shell.nix, which carries its
    # own launcher inside the shell.
    walker.url = "github:abenz1267/walker/v2.16.2";
    elephant.url = "github:abenz1267/elephant";

    # Omarchy 4, whose desktop is a single Quickshell process. Consumed by
    # omarchy-shell.nix, which takes the QML, themes, templates and scripts
    # straight from the tree rather than vendoring a curated list.
    omarchy-quattro = {
      url = "github:basecamp/omarchy/v4.0.0";
      flake = false;
    };

    # riso renders themes into the files the desktop reads. Published; for
    # local riso development:
    #   --override-input riso git+file:///home/eldios/go/src/github.com/riso/riso
    riso.url = "github:eldios/riso";

    # DankMaterialShell: a third desktop stack for desktop-switch. Not in
    # nixpkgs; its flake ships the dms CLI and shell as one package.
    dank-material-shell.url = "github:AvengeMedia/DankMaterialShell";

    # Caelestia: a fourth stack. Only the shell package from its flake is
    # used; the project's script-driven installer repo stays out.
    caelestia-shell.url = "github:caelestia-dots/shell";

    # Noctalia v5: a fifth stack, native Wayland with no Qt underneath. Kept
    # on its own nixpkgs so the official cachix binaries stay valid.
    noctalia.url = "github:noctalia-dev/noctalia";

    # AI tool overlays (auto-updated by maintainers)
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    opencode-nix.url = "github:dan-online/opencode-nix";
    llm-agents-nix.url = "github:numtide/llm-agents.nix"; # for crush (charmbracelet)
    gws-cli.url = "github:googleworkspace/cli";
    herdr.url = "github:ogulcancelik/herdr"; # agent multiplexer for AI CLIs (uses its own nixpkgs-unstable)

    # Zen Browser: community flake (per https://wiki.nixos.org/wiki/Zen_Browser)
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ratspeak: Reticulum/LXMF desktop client, own packaging flake
    # (builds against its own nixpkgs-unstable pin, like herdr)
    nix-ratspeak.url = "github:eldios/nix-ratspeak";

    # vm-curator: QEMU/KVM desktop VM TUI, packaged by its own upstream
    # flake. Pinned to the release tag; bump deliberately.
    vm-curator = {
      url = "github:mroboff/vm-curator/v1.4.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };
}
# vim: set nu li sw=2 ts=2 expandtab

