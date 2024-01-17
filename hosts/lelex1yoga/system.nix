{ pkgs , config , ... }:
{
  time.timeZone       = "Europe/Rome";
  i18n.defaultLocale  = "en_US.UTF-8";

  zramSwap.enable = true;
  systemd.services.zfs-mount.enable = false;

  system = {
    /* FIXME
    copySystemConfiguration = true;
    */
    stateVersion = "24.05";
    autoUpgrade.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command" "flakes"
  ];

  programs = {
    zsh.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;

      viAlias = true;
      vimAlias = true;

      configure = {
        customRC = ''
          set modeline
          colorscheme gruvbox
          set nu list sw=2 ts=2 expandtab
        '';
        package.myVimPackage = with pkgs.vimPlugins; {
          start = [
            vim-nix
            gruvbox
          ];
        };
      };
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "curses";
    };
  };

  services = {
    # # i3 config
    # xserver.enable = true;
    # xserver.displayManager.sddm.enable = true;
    # xserver.windowManager.i3.enable = true;

    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    openssh = {
      enable = true;
    };

    pcscd.enable = true;

    tailscale.enable = true;
  };

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs; [
    # hard reqs
    binutils
    git
    python3
    screen
    tmux
    libgcc
    pinentry-curses # required by GPG
    wget

    # Docker
    devspace
    docker
    docker-buildx
    kubernetes-helm
    k9s
    kind
    kubectl
    nerdctl

    # utils
    btop
    byobu
    #codeium
    colorls # like `ls --color=auto -F` but cooler
    cryptomator
    ffmpeg
    gnumake
    htop
    imagemagick
    just
    lshw
    manix
    neofetch
    rclone
    yt-dlp

    # Virtualisation
    virt-manager
    virtiofsd

    # WAYLAND + SWAY
    dbus   # make dbus-update-activation-environment available in the path
    glib # gsettings
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # audio
  sound.enable = true ;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "zfs";
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    containerd.enable = true;

    libvirtd.enable = true;
  };

  security.polkit.enable = true;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}

# vim: set ts=2 sw=2 et ai list nu
