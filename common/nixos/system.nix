{
  inputs,
  pkgs,
  nixpkgs-unstable,
  config,
  lib,
  ...
}:
let
  binDir = "/etc/profiles/per-user/eldios/bin";
in
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 10;
  };

  # Fix zram reconfiguration during nixos-rebuild switch
  # Reset the zram device if it already exists before trying to reconfigure it
  systemd.services."systemd-zram-setup@zram0" = {
    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "reset-zram0" ''
        set -e
        if [ -e /sys/block/zram0/reset ]; then
          # Ensure swap is off before reset
          ${pkgs.util-linux}/bin/swapoff /dev/zram0 2>/dev/null || true
          # Reset the device to allow reconfiguration
          echo 1 > /sys/block/zram0/reset || true
        fi
      '';
    };
  };

  systemd.services.zfs-mount.enable = false;
  systemd.services.NetworkManager-wait-online.enable = false;

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ./overlays/unstable-packages.nix { inherit nixpkgs-unstable; })
      (import ./overlays/custom-packages.nix)
    ];
  };

  # nix
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 31d";
    };
    extraOptions = ''
      !include ${config.sops.secrets."tokens/github/nix".path}
    '';
    settings = {
      # Nix Settings
      auto-optimise-store = true; # Auto Optimize nix store.
      experimental-features = [
        "nix-command"
        "flakes"
      ]; # Enable experimental features.
      trusted-users = [
        "root"
        "eldios"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  services = {
    fwupd.enable = true;

    fail2ban = {
      enable = true;
      # Ban IP after 5 failures
      maxretry = 5;
      ignoreIP = [
        # Whitelist some subnets
        "192.168.152.0/21"
      ];
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h"; # Do not ban for more than 1 week
        overalljails = true; # Calculate the bantime based on all the violations
      };

    };

    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowAgentForwarding = true;
      };
    };

    smartd = {
      enable = true;
      autodetect = true;
    };

    fstrim = {
      enable = true;
      interval = "daily";
    };

    pcscd.enable = true;

    tailscale = {
      enable = true;
      package = pkgs.unstable.tailscale;
    };

  };

  programs.nix-ld = {
    enable = true;
    libraries = [ ];
  };

  environment.shells = [
    "${binDir}/nu"
  ];

  programs.zsh = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    # basic shell pkgs
    bash

    # hard reqs
    binutils
    borgbackup
    btrfs-progs
    git
    gptfdisk
    libgcc
    nix-tree
    pinentry-curses # required by GPG
    python3
    ripgrep
    screen
    smartmontools
    sshuttle
    proxychains-ng
    tmux
    wget
    wireguard-tools

    # utils
    age
    btop
    byobu
    #colorls # like `ls --color=auto -F` but cooler
    ethtool
    fastfetch
    file
    ffmpeg
    gnumake
    htop
    just
    lsd
    lshw
    manix
    mdadm
    openssl
    rclone
    sops
    yubikey-personalization

    # WAYLAND + SWAY
    dbus # make dbus-update-activation-environment available in the path
    glib # gsettings

    # keyboard related stuff
    gvfs
    jmtpfs
    qmk
    qmk-udev-rules
    qmk_hid
    sof-firmware
    v4l-utils
    via
    vial
  ];

  hardware.keyboard.qmk.enable = true;
  services.udev.packages = with pkgs; [
    qmk
    qmk-udev-rules
    qmk_hid
    vial
    via
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
