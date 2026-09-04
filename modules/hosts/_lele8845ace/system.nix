{
  config,
  lib,
  pkgs,
  ...
}: {
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # 24 threads and 64GB here: allow more build parallelism than the
  # common default.
  nix.settings.cores = 12;

  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
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
    logind.settings.Login.HandlePowerKey = "ignore";

    # Always on mains, so only the charger profile ever applies: performance
    # governor with turbo, instead of the powersave governor set below.
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

    btrfs = {
      autoScrub = {
        enable = true;
        # Not "weekly" (Mon 00:00): that collides with nix-gc, fstrim and
        # docker prune. Scrub is the heaviest job (hours), so it gets its
        # own day, after the 04:40 nixos-upgrade window.
        interval = "Sat *-*-* 05:30:00";
      };
    };

    cloudflared.enable = true;

    displayManager = {
      sddm.enable = false;
      gdm.enable = true;
    };

    xserver = {
      enable = true;
      autorun = true;

      videoDrivers = ["amdgpu"];
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # https://wiki.archlinux.org/title/GPGPU#ICD_loader_(libOpenCL.so)
  environment.etc."ld.so.conf.d/00-usrlib.conf".text = "/usr/lib";

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # VDPAU on top of the VA-API stack the gpu-amd aspect installs.
    graphics = {
      enable32Bit = true;
      extraPackages = with pkgs; [
        libvdpau-va-gl
        libva-vdpau-driver
      ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

