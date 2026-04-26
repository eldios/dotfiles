{
  config,
  lib,
  pkgs,
  ...
}:

{
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # HOME - Italy - Rome
  time.timeZone = lib.mkForce "Europe/Rome";

  services = {
    # don't shutdown when power button is short-pressed
    logind.settings.Login.HandlePowerKey = "ignore";

    # BEGIN - laptop related stuff
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "schedutil";
          turbo = "auto";
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

    libinput = {
      enable = true;
      touchpad = {
        clickMethod = "clickfinger";
        #clickMethod = "buttonareas";
        disableWhileTyping = true;
        middleEmulation = false;
        tappingDragLock = false;
        tappingButtonMap = "lrm";
        scrollMethod = "twofinger";
      };
    };

    displayManager = {
      sddm.enable = false;
      gdm.enable = true;
      gdm.wayland = true;

      sessionPackages = with pkgs.unstable; [
        sway
        mangowc
      ];
    };

    xserver = {
      enable = true;
      autorun = true;

      videoDrivers = [ "modesetting" ];

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

  virtualisation.docker.storageDriver = "btrfs";

  environment.systemPackages = (
    with pkgs;
    [
      protonvpn-gui
    ]
  );

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

  # Unload/reload mt7921e WiFi module around S3 suspend to avoid
  # firmware timeout error -110 on resume.
  systemd.services."wifi-suspend-fix" = {
    description = "Unload mt7921e before sleep, reload on resume";
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/modprobe -r mt7921e";
      ExecStop = "${pkgs.kmod}/bin/modprobe mt7921e";
    };
  };

  # https://wiki.archlinux.org/title/GPGPU#ICD_loader_(libOpenCL.so)
  environment.etc."ld.so.conf.d/00-usrlib.conf".text = "/usr/lib";

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
        libva
        libva-utils
      ];
    };

    keyboard.qmk.enable = true;
  };

  # XDG portal, dbus, and PAM swaylock configured in desktop-gui.nix
  # Audio/pipewire configuration in common/nixos/audio.nix

  services.blueman.enable = true;

}

# vim: set ts=2 sw=2 et ai list nu
