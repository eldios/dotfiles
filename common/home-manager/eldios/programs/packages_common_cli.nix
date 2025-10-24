# Packages for common command-line interface tools, intended to be cross-platform.
{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # Dev Languages & Tools
      go
      cargo
      rustc
      rustfmt
      ghc
      bun
      nodejs
      nodenv
      pkg-config
      protobuf
      python3
      tree
      uv

      # DevOps & Cloud
      act # run GitHub Actions Locally
      age
      atac
      awscli2
      azure-cli
      bc
      cdrkit
      ddrescue
      dnsutils
      docker
      doctl # Digital Ocean CLI tool
      dysk
      gitleaks
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
      infisical
      jira-cli-go
      jless
      linode-cli
      kustomize
      kustomize-sops
      metal-cli # official Equinix Metal CLI
      openbao
      opentofu
      portal
      postman
      sops
      sshs
      terracognita
      terraform
      terraform-compliance
      terraform-landscape
      terraform-ls
      terraformer
      terraforming
      terragrunt
      terraspace
      tflint
      tflint-plugins.tflint-ruleset-aws
      tfswitch
      tmate
      vultr-cli

      # Kubernetes
      argocd
      daytona-bin
      devpod
      devspace
      eksctl
      helmfile
      k8sgpt
      k9s
      k0sctl
      kdash
      kind
      ktop
      kubectx
      kubelogin
      kubelogin-oidc
      kubernetes-helm
      skaffold
      teleport
      tfk8s
      vcluster
      yamlfmt
      yamllint

      # Nix Utilities
      cachix # adding/managing alternative binary caches hosted by Cachix
      comma # run software from without installing it
      niv # easy dependency management for nix projects
      nix-prefetch-git
      nix-prefetch-github
      nixfmt-rfc-style # in future this will be -> nixfmt
      nodePackages.node2nix
      prefetch-npm-deps

      # Charm.sh CLI Utils
      glow
      gum
      mods
      vhs
      zfxtop

      # General CLI Utilities
      asciiquarium
      bombadillo
      btop
      calcurse
      cbonsai
      cmatrix
      cowsay
      entr
      exfat
      fd # A simple, fast and user-friendly alternative to find
      figlet
      fortune
      gcc
      github-cli
      glances
      gnupg
      home-assistant-cli
      inetutils
      inxi
      just
      lolcat
      lzip
      mtr
      nix-tree
      nnn
      nyancat
      parallel
      pciutils
      pls
      psmisc
      pv
      pwgen
      qmk
      rclone
      ripgrep
      ripgrep-all
      sipcalc
      sl
      socat
      sshfs
      tldr
      tmux
      toilet
      unzip
      usbutils
      util-linux
      via
      vial
      wget
      magic-wormhole-rs
      yazi
      zip
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
