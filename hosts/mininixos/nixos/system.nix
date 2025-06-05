{ pkgs, ... }:
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

  systemd.services.disable-offload = {
    description = "Disable network offloading";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.ethtool}/bin/ethtool -K eno1 gro off tso off gso off";
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
