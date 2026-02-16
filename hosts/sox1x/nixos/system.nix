# `hardware.opengl.driSupport32Bit' has been renamed to `hardware.graphics.enable32Bit'.
# `hardware.opengl.enable' has been renamed to `hardware.graphics.enable'.
{ pkgs, ... }:
{
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  virtualisation.docker.storageDriver = "btrfs";

  services = {
    xserver = {
      xkb = {
        layout = "us"; #"it"
        variant = "";
      };
    };

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

    xserver = {
      enable = true;
      autorun = true;

      videoDrivers = [
        "nvidia"
      ];

      desktopManager = {
        cinnamon.enable = true;
      };
    };

    # CUPS
    printing.enable = true;
    # needed by CUPS for auto-discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  hardware = {
    enableAllFirmware = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

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

  xdg.portal = {
    enable = true;
    #wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # audio
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      configPackages = [ ];
    };
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

  security = {
    pam.services.swaylock = { };
  };

}

# vim: set ts=2 sw=2 et ai list nu
