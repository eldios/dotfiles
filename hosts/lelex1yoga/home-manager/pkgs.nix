{ pkgs, inputs, ... }:
let
  #unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux { config.allowUnfree = true; } ;
  unstablePkgs = import <nixpkgs-unstable> { config.allowUnfree = true; } ;
in
{
  home = {
    packages = (with pkgs; [
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
      slack
      spotify-unwrapped
      steam
      syncthing
      syncthing-cli
      syncthing-tray
      variety
      vesktop # discord + some fixes
      vscode
      widevine-cdm
      zoom-us

      # 2nd Brain stuff
      #obsidian

      # fonts
      corefonts
      anonymousPro
      meslo-lgs-nf
      font-awesome
      nerdfonts
      fira-code-nerdfont
    ]) # EOM pkgs
    ++ ( with unstablePkgs; [
      mailspring
    ]); # EOM unstablePkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
