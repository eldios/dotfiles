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
      slack
      spotify-unwrapped
      variety
      vesktop # discord + some fixes
      vivaldi # preferred browser
      vivaldi-ffmpeg-codecs # codecs for vivaldi
      vscode
      zoom-us
      steam
      pavucontrol
      geoclue2
      # 2nd Brain stuff
      syncthing
      syncthing-cli
      syncthing-tray
      #obsidian
      cryptomator


      # fonts
      corefonts
      anonymousPro
      meslo-lgs-nf
      font-awesome
      nerdfonts
      fira-code-nerdfont

      # BEGIN Sway confguration
      adwaita-qt
      adwaita-qt6
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      bemenu # wayland clone of dmenu
      clipman
      dconf
      dracula-theme # gtk theme
      eww-wayland # wayland widgets - https://github.com/elkowar/eww
      fuseiso
      fuzzel # wayland clone of dmenu
      gammastep
      geoclue2
      glpaper
      gnome.adwaita-icon-theme
      gnome.gnome-themes-extra
      gnome3.adwaita-icon-theme  # default gnome cursors
      grim # screenshot functionality
      grimblast # screenshot functionality
      gsettings-desktop-schemas
      hyprland-protocols
      hyprpaper
      hyprpicker
      kitty
      lavalauncher # simple launcher panel for Wayland desktops
      libva-utils
      mako # notification system developed by swaywm maintainer
      pinentry-bemenu
      polkit_gnome
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      rofi-wayland-unwrapped
      shotman
      slurp # screenshot functionality
      swaybg
      swayidle
      swaylock-effects
      swaynotificationcenter
      swayr
      swayrbar
      swww
      tofi
      udiskie
      wayland
      wbg
      wdisplays # tool to configure displays
      wev
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      wl-gammactl
      wl-screenrec
      wlogout
      wlr-randr
      wlroots
      wlsunset
      wofi
      wshowkeys
      wtype
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xdg-utils # for opening default programs when clicking links
      ydotool

      #fix-wm
      (pkgs.writeShellScriptBin "fix-wm" ''
        pkill waybar && sway reload
      '')
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
