{
  networking = {
    useDHCP = true; # OVH provides DHCP
    networkmanager.enable = false; # Server - use systemd-networkd

    hostName = "domevh";
    hostId = "d34d000a"; # random 8 hex chars - unique per host

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
      ];
    };
  };

  # Use systemd-networkd for cleaner server networking
  systemd.network.enable = true;
}

# vim: set ts=2 sw=2 et ai list nu
