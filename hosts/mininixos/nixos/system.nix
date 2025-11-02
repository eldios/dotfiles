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

  # TCP Offload Engine (TOE) is a technology used in modern NICs to move the
  # processing of the TCP/IP stack from the system’s main CPU to the NIC.
  # The processing overhead on the CPU increases with high-speed networks,
  # such as 10 Gigabit Ethernet. Moving some or all of the functionality of
  # the TCP/IP stack to the NIC helps in freeing the main CPU and improving
  # the network throughput.
  #systemd.services.disable-offload = {
  #  description = "Disable network offloading";
  #  after = [ "network.target" ];
  #  wantedBy = [ "multi-user.target" ];
  #  serviceConfig = {
  #    Type = "oneshot";
  #    RemainAfterExit = true;
  #    ExecStart = "${pkgs.ethtool}/bin/ethtool -K eno1 gro off tso off gso off";
  #  };
  #};
}

# vim: set ts=2 sw=2 et ai list nu
