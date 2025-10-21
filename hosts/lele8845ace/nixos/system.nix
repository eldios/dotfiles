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

  # Italy - Rome
  time.timeZone = lib.mkForce "Europe/Rome";

  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services = {
    hardware = {
      openrgb = {
        enable = true;
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

    # save and manage secrets and passwords
    gnome.gnome-keyring.enable = true;

    gvfs.enable = true;

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
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # https://wiki.archlinux.org/title/GPGPU#ICD_loader_(libOpenCL.so)
  environment.etc."ld.so.conf.d/00-usrlib.conf".text = "/usr/lib";

  environment.sessionVariables = {
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    T_QPA_PLATFORM = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  environment.variables = {
    # If cursor is not visible, try to set this to "on".
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    uinput.enable = true; # needed by xRemap

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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
      # needs to run the two following commands at restart
      # dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      # systemctl --user restart pipewire wireplumber xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
      sway.default = [
        "gtk"
        "wlr"
        "luminous"
      ];
      niri.default = [
        "gtk"
        "gnome"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-luminous
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  # Audio configuration moved to common/nixos/audio.nix

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
