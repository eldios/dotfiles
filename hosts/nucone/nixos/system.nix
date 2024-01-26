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
    codeium
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
    polkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
