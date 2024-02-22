{ lib, pkgs, inputs, ... }:
let
  #unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux { config.allowUnfree = true; } ;
  unstablePkgs = import <nixpkgs-unstable> { config.allowUnfree = true; } ;

  # obsidian - 2nd brain - patch taken from https://github.com/NixOS/nixpkgs/issues/273611
  obsidian = lib.throwIf (lib.versionOlder "1.4.16" pkgs.obsidian.version) "Obsidian no longer requires EOL Electron" (
    pkgs.obsidian.override {
      electron = pkgs.electron_25.overrideAttrs (_: {
        preFixup = "patchelf --add-needed ${pkgs.libglvnd}/lib/libEGL.so.1 $out/bin/electron"; # NixOS/nixpkgs#272912
        meta.knownVulnerabilities = [ ]; # NixOS/nixpkgs#273611
      });
    }
  );
in
{
  home = {
    packages = ([ obsidian ]) ++ (with pkgs; [
      # CLI utils
      fd # A simple, fast and user-friendly alternative to find
      sshfs
      pciutils
      socat
      asciiquarium
      awscli2
      bombadillo
      btop
      calcurse
      cava
      cavalier
      cbonsai
      cmatrix
      cointop
      colorls
      cowsay
      element # show the period table on the command line
      figlet
      flameshot
      fortune
      gcal
      github-cli
      glances
      graph-easy
      graphviz
      iotop
      just
      lolcat
      mtr
      ncdu
      neofetch
      networkmanager
      nyancat
      parallel
      pciutils
      pdfposter
      playerctl
      pls
      powertop
      pv
      pwgen
      ranger
      ripgrep
      ripgrep-all
      sipcalc
      thefuck
      tldr
      tmux
      toilet
      whois
      wmctrl
      yubikey-personalization
      yazi

      # DevOps Experimental stuff
      devspace
      devpod
      skaffold
      helmfile
      terracognita
      terraform
      opentofu
      terraform-compliance
      terraform-landscape
      terraformer
      terraforming
      terragrunt
      terraspace
      terraform-ls
      tflint
      tflint-plugins.tflint-ruleset-aws
      tfswitch
      vcluster

      # DevOps (Kubernetes, Terraform, etc..) stuff
      eksctl
      k9s
      kind
      kubectl
      kubelogin
      kubelogin-oidc
      kubernetes-helm
      nodejs
      bun
      nodenv
      temporal-cli
      tfk8s
      yamlfmt
      yamllint

      # charm.sh CLI utils
      gum
      vhs
      glow
      mods
      zfxtop

      # nix stuff
      cachix # adding/managing alternative binary caches hosted by Cachix
      comma # run software from without installing it
      niv # easy dependency management for nix projects
      nix-prefetch-git
      nix-prefetch-github
      nixfmt
      nodePackages.node2nix
      prefetch-npm-deps

      # GUI stuff
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      beeper
      bitwarden
      brave
      cryptomator
      # davinci-resolve
      discord
      geoclue2
      kitty
      light # brightness control
      paperview
      pavucontrol
      redshift
      signal-desktop
      slack
      spotify-unwrapped
      steam
      syncthing
      syncthing-cli
      syncthing-tray
      telegram-desktop
      variety
      vesktop # discord + some fixes
      vscode
      whatsapp-for-linux
      widevine-cdm
      zoom-us

      # fonts
      anonymousPro
      corefonts
      fira-code-nerdfont
      font-awesome
      meslo-lgs-nf
      nerdfonts
    ]) # EOM pkgs
    ++ ( with unstablePkgs; [
      mailspring
    ]); # EOM unstablePkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
