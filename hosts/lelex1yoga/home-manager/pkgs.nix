{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
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

      # GUI stuff
      beeper
      (bluemail.overrideAttrs (previousAttrs: {
        src = pkgs.fetchurl {
          url  = "https://download.bluemail.me/BlueMail/deb/BlueMail.deb";
          hash = "sha256-L9mCUjsEcalVxzl80P3QzVclCKa75So2sBG7KjjBVIc=";
        };
      }))
      #fix-wm
      (pkgs.writeShellScriptBin "bluemail-wayland" ''
        ${pkgs.bluemail}/bin/bluemail --no-sandbox
      '')
      # davinci-resolve
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      cryptomator
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
      vivaldi # preferred browser
      vivaldi-ffmpeg-codecs # codecs for vivaldi
      vscode
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
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
