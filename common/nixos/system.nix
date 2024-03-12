{ inputs , pkgs , config , lib , ... }:
{
  zramSwap.enable = true;
  systemd.services.zfs-mount.enable = false;

  # workaround as shown here https://github.com/NixOS/nixpkgs/issues/180175#issuecomment-1658731959
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
    };
  };

  environment.variables.EDITOR = "nvim";
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

    openssh = {
      enable = true;
    };

    smartd = {
      enable = true;
      autodetect = true;
    };

    pcscd.enable = true;

    tailscale.enable = true;

  };

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
    zfs
    btrfs-progs
    smartmontools
    nix-tree

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
    fastfetch
    rclone
    yt-dlp

    # WAYLAND + SWAY
    dbus   # make dbus-update-activation-environment available in the path
    glib # gsettings
  ];

  security = {
    polkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
