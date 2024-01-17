{ pkgs, ... }:
{
    packages = with pkgs; [
      # CLI utils
      asciiquarium
      awscli2
      bombadillo
      btop
      cava
      cavalier
      cbonsai
      cmatrix
      cointop
      colorls
      cowsay
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
      networkmanager
      ncdu
      neofetch
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
      wmctrl
      whois
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
      cryptomator
      discord
      light # brightness control
      paperview
      redshift
      kitty
      spotify
      variety
      vesktop # discord + some fixes
      vivaldi # preferred browser
      vivaldi-ffmpeg-codecs # codecs for vivaldi
      vscode

      # fonts
      anonymousPro
      meslo-lgs-nf
      font-awesome
      nerdfonts
      fira-code-nerdfont

      # BEGIN Sway confguration
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      #dbus-sway-environment
      #configure-gtk
      wayland
      xdg-utils # for opening default programs when clicking links
      dracula-theme # gtk theme
      gnome3.adwaita-icon-theme  # default gnome cursors
      swaylock
      swayidle
      shotman
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      bemenu # wayland clone of dmenu
      mako # notification system developed by swaywm maintainer
      wdisplays # tool to configure displays
    ];
}

# vim: set ts=2 sw=2 et ai list nu
