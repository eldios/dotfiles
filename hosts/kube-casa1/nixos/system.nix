{ ... }:
{
  system = {
    stateVersion = "25.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  virtualisation.docker.storageDriver = "zfs";

  services = {
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      trim.enable = true;
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
