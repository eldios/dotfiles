{ config, lib, pkgs, nixpkgs-unstable, ... }:
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
    stateVersion = "24.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
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
  ]);

  programs = {
    nix-ld = {
      enable = true;
      libraries = [];
    };

    steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
    streamdeck-ui = {
      enable = true;
      autoStart = true;
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # https://wiki.archlinux.org/title/GPGPU#ICD_loader_(libOpenCL.so)
  environment.etc."ld.so.conf.d/00-usrlib.conf".text = "/usr/lib";

  systemd.services.portmaster = {
    enable = true;

    description = "Portmaster by Safing";

    unitConfig = {
      Documentation = [
        "https://safing.io"
        "https://docs.safing.io"
      ];
      Before = [
        "nss-lookup.target"
        "network.target"
        "shutdown.target"
      ];
      After = "systemd-networkd.service";
      Conflicts = [
        "shutdown.target"
        "firewalld.service"
      ];
      Wants = "nss-lookup.target";
    };

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 10;
      LockPersonality = "yes";
      MemoryDenyWriteExecute = "yes";
      NoNewPrivileges = "yes";
      PrivateTmp = "yes";
      PIDFile = "/opt/safing/portmaster/core-lock.pid";
      Environment = [
        "LOGLEVEL=info"
        "PORTMASTER_ARGS="
      ];
      EnvironmentFile = "-/etc/default/portmaster";
      ProtectSystem = "true";
      #ReadWritePaths = "/var/lib/portmaster";
      #ReadWritePaths = "/run/xtables.lock";
      RestrictAddressFamilies = "AF_UNIX AF_NETLINK AF_INET AF_INET6";
      RestrictNamespaces = "yes";
      # In future version portmaster will require access to user home
      # directories to verify application permissions.
      ProtectHome = "read-only";
      ProtectKernelTunables = "yes";
      ProtectKernelLogs = "yes";
      ProtectControlGroups = "yes";
      PrivateDevices = "yes";
      AmbientCapabilities = "cap_chown cap_kill cap_net_admin cap_net_bind_service cap_net_broadcast cap_net_raw cap_sys_module cap_sys_ptrace cap_dac_override cap_fowner cap_fsetid";
      CapabilityBoundingSet = "cap_chown cap_kill cap_net_admin cap_net_bind_service cap_net_broadcast cap_net_raw cap_sys_module cap_sys_ptrace cap_dac_override cap_fowner cap_fsetid";
      # SystemCallArchitectures = "native";
      # SystemCallFilter = "@system-service @module";
      # SystemCallErrorNumber = "EPERM";
      ExecStart = "/opt/safing/portmaster/portmaster-start --data /opt/safing/portmaster core -- $PORTMASTER_ARGS";
      ExecStopPost = "-/opt/safing/portmaster/portmaster-start recover-iptables";
    };

    wantedBy = [ "multi-user.target" ];
  };

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
    # intel-compute-runtime
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        libva
        libva-utils
        intel-graphics-compiler
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        onevpl-intel-gpu
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
  sound.enable = true;
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
