{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # CLI utils
      nil # NIx Language server
      fd # A simple, fast and user-friendly alternative to find
      sshfs
      pciutils
      socat
      asciiquarium
      awscli2
      bombadillo
      btop
      calcurse
      cointop
      colorls
      cowsay
      element # show the period table on the command line
      figlet
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
      pv
      pwgen
      ranger
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

      # nvim stuff
      carapace
      rnix-lsp
      terraform-ls
      terraform-lsp
      typescript

      # GUI stuff
      syncthing
      syncthing-cli
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
