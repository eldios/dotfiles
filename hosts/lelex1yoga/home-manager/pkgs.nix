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

      # nvim stuff
      carapace
      rnix-lsp
      terraform-ls
      terraform-lsp
      typescript

      # GUI stuff
      beeper
      cryptomator
      # davinci-resolve
      discord
      kitty
      light # brightness control
      paperview
      redshift
      spotify-unwrapped
      variety
      vesktop # discord + some fixes
      vivaldi # preferred browser
      vivaldi-ffmpeg-codecs # codecs for vivaldi
      vscode
      zoom-us

      # fonts
      corefonts
      anonymousPro
      meslo-lgs-nf
      font-awesome
      nerdfonts
      fira-code-nerdfont

      # BEGIN Sway confguration
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      bemenu # wayland clone of dmenu
      fuzzel # wayland clone of dmenu
      dconf
      dracula-theme # gtk theme
      eww-wayland # wayland widgets - https://github.com/elkowar/eww
      gnome3.adwaita-icon-theme  # default gnome cursors
      grim # screenshot functionality
      grimblast # screenshot functionality
      lavalauncher # simple launcher panel for Wayland desktops
      mako # notification system developed by swaywm maintainer
      pinentry-bemenu
      shotman
      slurp # screenshot functionality
      swaybg
      swayidle
      swaylock-effects
      swayr
      swayrbar
      rofi-wayland-unwrapped
      tofi
      wofi
      wayland
      wdisplays # tool to configure displays
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      xdg-utils # for opening default programs when clicking links

      glpaper
      wbg
      wev
      wl-clipboard
      wl-gammactl
      gammastep
      geoclue2
      wl-screenrec
      wlogout
      wlroots
      wlsunset
      wofi
      wshowkeys
      wtype
      clipman

      #fix-wm
      (pkgs.writeShellScriptBin "fix-wm" ''
        pkill waybar && sway reload
      '')
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
