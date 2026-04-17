# `hardware.opengl.driSupport32Bit' has been renamed to `hardware.graphics.enable32Bit'.
# `hardware.opengl.enable' has been renamed to `hardware.graphics.enable'.
{ pkgs, lib, ... }:
{
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  virtualisation.docker.storageDriver = "btrfs";

  services = {
    xserver = {
      enable = true;
      autorun = true;

      xkb = {
        layout = "us"; #"it"
        variant = "";
      };

      videoDrivers = [
        "nvidia"
      ];

      desktopManager = {
        cinnamon.enable = true;
      };
    };

    # Gnome (latest) available alongside Cinnamon — user picks at GDM login
    desktopManager.gnome.enable = true;

    # Cinnamon-friendly defaults
    cinnamon.apps.enable = true;

    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    cloudflared.enable = true;

    libinput = {
      enable = true;
      touchpad = {
        clickMethod = "buttonareas";
        #clickMethod = "clickfinger";
        disableWhileTyping = true;
      };
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

    # CUPS
    printing.enable = true;
    # needed by CUPS for auto-discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    blueman.enable = true;
  };

  # dconf is used by both Cinnamon and Gnome for settings persistence
  programs.dconf.enable = true;

  # Trim Gnome default bloat (keeps Gnome lean when user picks it at GDM)
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-tour
    gnome-weather
    gnome-connections
  ];

  environment.systemPackages = with pkgs; [
    # Cinnamon extras
    cinnamon-common
    nemo-with-extensions
    file-roller

    # Gnome extras (available when logged into Gnome session)
    gnome-tweaks
    gnome-extension-manager
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
  ];

  # Cinnamon and Gnome both define NIX_GSETTINGS_OVERRIDES_DIR. They can't
  # coexist — force empty so both sessions fall back to upstream gsettings
  # defaults (no NixOS-specific overrides, but both DEs boot cleanly).
  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "";

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  hardware = {
    enableAllFirmware = true;

    graphics = {
      enable = true;
      enable32Bit = true;
      #extraPackages = with pkgs; [ ];
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

  # Bluetooth, XDG portal, D-Bus, gnome-keyring, gvfs, upower, swaylock PAM, ssh askpass
  # are provided by common/nixos/desktop-gui.nix.
  # Audio (pipewire + audiophile rules) is provided by common/nixos/audio.nix.
}

# vim: set ts=2 sw=2 et ai list nu
