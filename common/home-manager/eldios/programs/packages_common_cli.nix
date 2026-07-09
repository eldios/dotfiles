# Packages for common command-line interface tools, intended to be cross-platform.
{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # Dev Languages & Runtimes
      bun # fast JavaScript runtime and bundler
      cargo # Rust package manager
      gcc # GNU C/C++ compiler
      ghc # Glasgow Haskell Compiler
      go # Go programming language
      nodejs # JavaScript runtime
      nodenv # Node.js version manager
      rustc # Rust compiler
      rustfmt # Rust code formatter
      uv # fast Python package manager

      # Python3 related packages
      python3 # Python 3 interpreter
      python3Packages.pytest # Python testing suite

      # Dev & Build Tools
      act # run GitHub Actions locally
      distrobox # Wrapper around podman or docker to create and start containers
      distrobox-tui # TUI for DistroBox
      distroshelf # GUI for Distrobox Containers
      entr # run commands when files change
      github-cli # GitHub from the terminal
      herdr # agent multiplexer for AI coding agents (via herdr flake overlay)
      gitbutler # visual Git client for branches
      gitbutler-cli # GitButler CLI (but)
      just # command runner (Makefile alternative)
      pkg-config # build helper for compiled libraries
      protobuf # protocol buffer compiler
      sloc # source lines of code counter
      semgrep # static analysis code tool
      shellcheck # shell script linter

      # Cloud CLIs
      awscli2 # Amazon Web Services CLI
      azure-cli # Microsoft Azure CLI
      doctl # DigitalOcean CLI
      (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ]) # GCP CLI with GKE auth
      infisical # secrets management platform CLI
      jira-cli-go # Jira CLI
      linode-cli # Linode cloud CLI
      metal-cli # Equinix Metal CLI
      vultr-cli # Vultr cloud CLI

      # IaC (Terraform & OpenTofu)
      opentofu # open-source Terraform alternative
      terracognita # import existing cloud resources to IaC
      terraform # infrastructure as code
      terraform-compliance # BDD testing for Terraform plans
      terraform-landscape # improved Terraform plan output
      terraform-ls # Terraform language server
      terraformer # generate IaC from existing infrastructure
      terraforming # export AWS resources to Terraform
      terragrunt # Terraform wrapper for DRY configs
      terraspace # Terraform framework
      tflint # Terraform linter
      tflint-plugins.tflint-ruleset-aws # AWS rules for tflint
      tfswitch # Terraform version manager

      # Kubernetes
      argocd # GitOps continuous delivery for Kubernetes
      devpod # dev environments as code
      devspace # cloud-native dev workflow tool
      eksctl # Amazon EKS cluster manager
      helmfile # declarative Helm chart manager
      k0sctl # k0s Kubernetes distribution manager
      k8sgpt # AI-powered Kubernetes diagnostics
      k9s # TUI for Kubernetes clusters
      kind # Kubernetes in Docker for local testing
      ktop # top-like TUI for Kubernetes nodes
      kubeconform # Kubernetes manifest validator
      kubectx # switch between k8s contexts/namespaces
      kubernetes-helm # Kubernetes package manager
      kustomize # Kubernetes manifest customization
      kustomize-sops # SOPS integration for Kustomize
      skaffold # local Kubernetes dev workflow
      teleport # secure infrastructure access gateway
      tfk8s # convert Kubernetes YAML to Terraform HCL
      vcluster # virtual Kubernetes clusters
      yamlfmt # YAML formatter
      yamllint # YAML linter

      # Containers
      docker # container runtime
      oxker # TUI for Docker container management

      # Networking & SSH
      dnsutils # DNS query tools (dig, nslookup)
      inetutils # classic network tools (ftp, telnet, etc.)
      magic-wormhole-rs # secure file transfer between devices
      mtr # network diagnostic (traceroute + ping)
      portal # secure peer-to-peer file transfer
      sipcalc # IP subnet calculator
      socat # multipurpose network relay tool
      sshfs # mount remote filesystems via SSH
      sshs # TUI SSH client manager
      tmate # instant terminal sharing via SSH

      # Security & Secrets
      age # modern file encryption tool
      gitleaks # detect secrets in git repos
      gnupg # GPG encryption suite
      openbao # open-source secrets manager (Vault fork)
      pwgen # random password generator
      sops # encrypt secrets in config files

      # API & HTTP Clients
      atac # TUI API client for HTTP requests
      jless # JSON viewer in terminal
      posting # TUI HTTP client
      postman # API development and testing platform

      # Nix Utilities
      cachix # manage alternative Nix binary caches
      comma # run software without installing it
      niv # dependency management for Nix projects
      nix-prefetch-git # prefetch Git repos for Nix
      nix-prefetch-github # prefetch GitHub repos for Nix
      nix-tree # visualize Nix store dependencies
      nixfmt # Nix code formatter (RFC style)
      prefetch-npm-deps # prefetch npm dependencies for Nix

      # Charm.sh CLI Utils
      glow # markdown renderer for terminal
      gum # interactive shell script components
      mods # AI on the command line
      vhs # CLI screen recorder to GIF
      zfxtop # TUI system monitor with eye candy

      # File Management & Search
      fd # fast find alternative
      nnn # lightweight terminal file manager
      pls # modern ls alternative with icons
      rclone # cloud storage sync tool
      ripgrep # fast regex search tool
      ripgrep-all # ripgrep for PDFs, archives, etc.
      superfile # modern terminal file manager with TUI
      tree # directory listing as a tree
      yazi # fast terminal file manager

      # Disk & Storage
      bc # arbitrary precision calculator
      caligula # dd with a TUI
      cdrkit # CD/DVD recording tools
      ddrescue # data recovery tool for damaged media
      dysk # disk usage analyzer with TUI
      exfat # ExFAT filesystem tools
      lzip # lossless data compressor
      pv # pipe viewer for monitoring data flow
      unzip # extract ZIP archives
      zip # create ZIP archives

      # System Monitoring & Info
      below # system resource monitor (cgroup-aware)
      btop # resource monitor with TUI
      glances # cross-platform system monitoring tool
      inxi # system information tool
      pciutils # PCI device info (lspci)
      psmisc # process tools (killall, pstree)
      usbutils # USB device info (lsusb)
      util-linux # core Linux system utilities

      # Keyboard Firmware
      qmk # QMK keyboard firmware toolkit
      via # VIA keyboard configurator
      vial # Vial keyboard configurator (open-source)

      # Smart Home
      home-assistant-cli # Home Assistant CLI

      # Misc CLI Tools
      bombadillo # Gemini/Gopher TUI browser
      calcurse # calendar and scheduler TUI
      cointop # cryptocurrency portfolio tracker TUI
      gophertube # YouTube TUI client via Gopher
      parallel # execute commands in parallel
      tldr # simplified community-driven man pages
      tmux # terminal multiplexer
      wget # download files from the web

      # Terminal Fun
      asciiquarium # aquarium animation in terminal
      cbonsai # bonsai tree generator in terminal
      cmatrix # Matrix digital rain effect
      cowsay # ASCII art cow with message
      figlet # create ASCII text banners
      fortune # random quote generator
      lolcat # rainbow colored text output
      nyancat # Nyan Cat animation in terminal
      sl # steam locomotive (typo catcher for ls)
      toilet # ASCII art text with colors
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
