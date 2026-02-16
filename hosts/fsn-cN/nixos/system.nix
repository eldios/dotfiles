{ lib, ... }:
{
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  services = {
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      trim.enable = true;
    };

    smartd.enable = lib.mkForce false;
  };

}

# vim: set ts=2 sw=2 et ai list nu
