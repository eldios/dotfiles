{ config, inputs, lib, pkgs, nixpkgs-unstable, peerix, portmaster, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  system = {
    stateVersion = "24.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
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

  environment.systemPackages = (with pkgs; [
    clinfo
  ]) ++ (with unstablePkgs; [ ]) ++ [ ];

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
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
