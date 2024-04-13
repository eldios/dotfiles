{ pkgs, ... }:
{
  system = {
    stateVersion = "23.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    cloudflared.enable = true;

    xserver = {
      enable = true;
      autorun = true;

      displayManager = {
        sddm.enable = false;

        gdm.enable = true;
        gdm.wayland = true;

        sessionPackages = with pkgs; [ 
          sway
          hyprland
        ];
      };
    };

    # CUPS
    printing.enable = true;
    # needed by CUPS for auto-discovery
    avahi = {
      enable       = true;
      nssmdns      = true;
      openFirewall = true;
    };
  };

  # run Android apps on linux
  virtualisation.waydroid.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  hardware = {
    enableAllFirmware = true;

    uinput.enable = true; # needed by xRemap

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
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        #vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*" ;
    # gtk portal needed to make gtk apps happy
    extraPortals = [
      #pkgs.xdg-desktop-portal-gtk
      #pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  users.users.eldios.extraGroups = [
    "input" # needed by xRemap
    "uinput" # needed by xRemap
  ];

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

  security = {
    pam.services.swaylock = {};
  };

}

# vim: set ts=2 sw=2 et ai list nu
