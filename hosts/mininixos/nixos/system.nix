{
  system = {
    stateVersion = "23.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
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

    cockpit = {
      enable = false;
      openFirewall = true;
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
