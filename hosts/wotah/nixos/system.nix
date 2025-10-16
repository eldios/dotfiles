{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Kernel modules and options for GPU passthrough
  boot.kernelModules = [
    "vfio-pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.blacklistedKernelModules = [
    "nvidia"
    "nouveau"
    "nvidiafb"
    "rivafb"
  ];
  boot.extraModprobeConfig = "options vfio-pci ids=10de:XXXX,10de:YYYY # FIXME: Replace 10de:XXXX and 10de:YYYY with actual Nvidia 3090 GPU and Audio device IDs respectively";

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
    fprintd = {
      enable = true;
    };

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = ''
      HandlePowerKey=ignore
    '';

    # BEGIN - laptop related stuff
    thermald.enable = true;
    auto-cpufreq = {
      enable = true;
      settings = {
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
  };

  virtualisation.docker.storageDriver = "btrfs";

  environment.systemPackages =
    (with pkgs; [
      clinfo
    ])
    ++ (with pkgs.unstable; [ ])
    ++ [ ];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
    powertop.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      enable = true;
    };

    nvidia = {
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        sync = {
          enable = false;
        };
        offload = {
          enable = false;
        };
        reverseSync = {
          enable = false;
        };
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
