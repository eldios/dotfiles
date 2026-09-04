{
  pkgs,
  lib,
  ...
}: {
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  # Laptop: sleep allowed, lid behavior from the base suspend module
  machine.suspend.enable = true;

  virtualisation.docker.storageDriver = "zfs";

  services = {
    xserver.desktopManager.cinnamon.enable = true;

    # Gnome (latest) available alongside Cinnamon: user picks at GDM login
    desktopManager.gnome.enable = true;

    # Cinnamon-friendly defaults
    cinnamon.apps.enable = true;

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
      sessionPackages = with pkgs; [
        hyprland
      ];
    };
  };

  # Trim Gnome default bloat (keeps Gnome lean when user picks it at GDM)
  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-tour
    gnome-weather
    gnome-connections
  ];

  environment.systemPackages = with pkgs; [
    # Cinnamon extras
    cinnamon-common
    nemo-with-extensions
    file-roller

    # Gnome extras (available when logged into Gnome session)
    gnome-tweaks
    gnome-extension-manager
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    gnomeExtensions.clipboard-indicator
  ];

  # Cinnamon and Gnome both define NIX_GSETTINGS_OVERRIDES_DIR. They can't
  # coexist: force empty so both sessions fall back to upstream gsettings
  # defaults (no NixOS-specific overrides, but both DEs boot cleanly).
  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "";

  # Power-profiles-daemon comes with the desktop sessions, so the laptop
  # aspect's auto-cpufreq cannot run here; the governor is set directly.
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  # PCI ids of the iGPU and the dGPU for PRIME offload.
  hardware.nvidia.prime = {
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:01:0:0";
  };
}
# vim: set ts=2 sw=2 et ai list nu

