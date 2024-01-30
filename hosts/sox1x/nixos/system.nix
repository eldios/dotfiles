{ inputs , pkgs , config , lib , ... }:
{
  zramSwap.enable = true;
  systemd.services.zfs-mount.enable = false;

  system = {
    stateVersion = "23.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

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

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # nix
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    settings = { # Nix Settings
      auto-optimise-store = true; # Auto Optimize nix store.
      experimental-features = [ "nix-command" "flakes" ]; # Enable experimental features.
    };
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  services = {

    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    openssh = {
      enable = true;
    };

    pcscd.enable = true;

    tailscale.enable = true;

    xserver = {
      enable = true;
      autorun = true;

      libinput.enable = true;

      videoDrivers = [
        "nvidia"
      ];

      desktopManager = {
        cinnamon.enable = true;
      };

      displayManager = {

        defaultSession = "cinnamon";

        gdm.enable = true;
        gdm.wayland = true;

        sessionPackages = with pkgs; [ 
          sway
          hyprland
        ];
      };
    };
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
    ripgrep

    # Docker
    docker
    docker-buildx
    nerdctl

    # utils
    btop
    byobu
    codeium
    colorls # like `ls --color=auto -F` but cooler
    ffmpeg
    gnumake
    htop
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

  hardware = {
    # use pipewire instead
    pulseaudio.enable = false;

    bluetooth = {
      enable = true;
      powerOnBoot = true ;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    opengl = {
      enable = true;

      driSupport      = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [ ];
    };

    nvidia = {
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:01:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      powerManagement.enable = false;
      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      # Currently alpha-quality/buggy, so false is currently the recommended setting.
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      #package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  xdg.portal = {
    enable = true;
    #wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    config.common.default = "*" ;
    extraPortals = [
      #pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };


  # audio
  sound.enable = true ;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.blueman = {
    enable = true;
  };


  # xdg-desktop-portal works by exposing a series of D-Bus interfaces
  # known as portals under a well-known name
  # (org.freedesktop.portal.Desktop) and object path
  # (/org/freedesktop/portal/desktop).
  # The portal interfaces include APIs for file access, opening URIs,
  # printing and others.
  services.dbus.enable = true;

  # Add any users in the 'wheel' group to the 'libvirt' group.
  users.groups.libvirt.members = builtins.filter (x: builtins.elem "wheel" config.users.users."${x}".extraGroups) (builtins.attrNames config.users.users);
  virtualisation = {

    containerd.enable = true;
    docker = {
      enable = true;
      storageDriver = "zfs";
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    libvirtd = {
      enable = true;

      qemu = {
        ovmf.enable = true;
        runAsRoot = false;
      };

      onBoot = "ignore";
      onShutdown = "shutdown";
    };
  };

  security = {
    pam.services.swaylock = {};

    polkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

}

# vim: set ts=2 sw=2 et ai list nu
