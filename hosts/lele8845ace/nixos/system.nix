{
  config,
  lib,
  pkgs,
  ...
}:

{
  system = {
    stateVersion = "25.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Italy - Rome
  time.timeZone = lib.mkForce "Europe/Rome";

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services = {
    hardware = {
      openrgb = {
        enable = false; # disabled since mbed-tls is insecure for now
        motherboard = "amd";
        package = pkgs.openrgb-with-all-plugins;
      };
    };

    fprintd = {
      enable = true;
    };

    # don't shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    # BEGIN - laptop related stuff
    thermald.enable = true;
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
    # END - laptop related stuff
    btrfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
    };

    cloudflared.enable = true;

    displayManager = {
      sddm.enable = false;

      sessionPackages = with pkgs.unstable; [
        sway
        hyprland
      ];
    };

    xserver = {
      enable = true;
      autorun = true;

      videoDrivers = [ "amdgpu" ];

      displayManager = {
        gdm.enable = true;
        gdm.wayland = true;
      };

      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [
            dmenu
            i3status
            i3lock
            i3blocks
          ];
        };
      };
    };

    # gnome-keyring and gvfs configured in desktop-gui.nix

    # CUPS
    printing.enable = true;
    # needed by CUPS for auto-discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # run Android apps on linux
  virtualisation.docker.storageDriver = "btrfs";

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      # Fix CEF GPU rendering issues on AMD with i3 workspace switching
      package = pkgs.steam.override {
        extraArgs = "-no-cef-sandbox -cef-disable-gpu";
      };
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # https://wiki.archlinux.org/title/GPGPU#ICD_loader_(libOpenCL.so)
  environment.etc."ld.so.conf.d/00-usrlib.conf".text = "/usr/lib";

  # NOTE: WM-specific env vars (GDK_BACKEND, QT_QPA_PLATFORM, NIXOS_OZONE_WL,
  # XDG_CURRENT_DESKTOP, XDG_SESSION_TYPE, etc.) are now set per-WM:
  # - Hyprland: common/home-manager/eldios/programs/hyprland.nix
  # - i3:       common/home-manager/eldios/programs/i3.nix
  # This allows switching between X11 (i3) and Wayland (Hyprland) without conflicts.

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # uinput and bluetooth configured in desktop-gui.nix

    # https://wiki.archlinux.org/title/GPGPU
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
        rocmPackages.clr.icd
        vaapiVdpau
      ];
    };

    amdgpu = {
      amdvlk = {
        enable = true;
        support32Bit.enable = true;
        supportExperimental.enable = true;
      };
      opencl.enable = true;
      initrd.enable = true;
    };

    keyboard.qmk.enable = true;
  };

  # XDG portal, dbus, and PAM swaylock configured in desktop-gui.nix
  # Audio configuration in common/nixos/audio.nix

}

# vim: set ts=2 sw=2 et ai list nu
