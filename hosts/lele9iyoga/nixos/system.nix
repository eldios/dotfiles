{ config, lib, pkgs, nixpkgs-unstable, portmaster, peerix, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  #secretspath = builtins.toString inputs.secrets;
  #intel-compute-runtime-fix-arc = unstablePkgs.intel-compute-runtime.overrideAttrs (_finalAttrs: _previousAttrs: {
  #  version = "fix-arc";

  #  src = unstablePkgs.fetchFromGitHub {
  #    owner = "smunaut";
  #    repo = "compute-runtime";
  #    rev = "3bc54ac0140cc6ff985590dc90330bb8229535c5";
  #    hash = "sha256-aamf9WeWihzfvAsFRA5RanBr8+flc2dS+hjV+jOfZKQ=";
  #  };
  #});
  #davinci-resolve-studio = unstablePkgs.davinci-resolve-studio.override (old: {
  #  buildFHSEnv = a: (old.buildFHSEnv (a // {
  #    extraBwrapArgs = a.extraBwrapArgs ++ [
  #      "--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL"
  #    ];
  #  }));
  #});
in
{
  system = {
    stateVersion = "24.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  # Italy - Rome
  time.timeZone = lib.mkForce "Europe/Rome";
  # Los Angeles
  # time.timeZone = lib.mkForce "America/Los_Angeles";

  services = {
    # don’t shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    peerix = {
      enable = true;
      package = peerix.packages.${pkgs.system}.peerix;
      openFirewall = false;
      #privateKeyFile = config.sops.secrets."keys/peerix/private".path;
      #publicKeyFile = config.sops.secrets."keys/peerix/public".path;
      #publicKey = "key1 key2 key3";
    };

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

      sessionPackages = with unstablePkgs; [
        sway
        hyprland
      ];
    };

    xserver = {
      enable = true;
      autorun = true;

      videoDrivers = [ "modesetting" ];

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
  virtualisation.waydroid.enable = false;
  virtualisation.docker.storageDriver = "btrfs";

  environment.systemPackages = (with pkgs; [
    gvfs
    jmtpfs
    qmk
    qmk-udev-rules
    qmk_hid
    sof-firmware
    v4l-utils
    vial
  ]) ++ (with unstablePkgs; [
    davinci-resolve-studio
  ]) ++ [
    portmaster.legacyPackages.${pkgs.system}.portmaster
  ];

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

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
        libva
        libva-utils
        intel-graphics-compiler
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vpl-gpu-rt
        intel-compute-runtime
      ] ++ [ ];
      #extraPackages32 = with pkgs.pkgsi686Linux; [
      #  intel-vaapi-driver
      #];
    };

    keyboard.qmk.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      #pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # audio
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = false;
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

  services.udev.packages = [ pkgs.via ];

  security = {
    pam.services.swaylock = { };
  };

}

# vim: set ts=2 sw=2 et ai list nu
