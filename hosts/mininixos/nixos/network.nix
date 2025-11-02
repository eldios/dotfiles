{
  # Rename interfaces based on MAC address to predictable names
  systemd.network.links = {
    "10-eno0" = {
      matchConfig.MACAddress = "58:47:ca:7d:39:8e";
      linkConfig.Name = "eno0";
    };
    "10-wlan0" = {
      matchConfig.MACAddress = "58:47:ca:7d:39:8e";
      linkConfig.Name = "wlan0";
    };
  };

  networking = {
    usePredictableInterfaceNames = false; # We handle naming via systemd.network.links
    networkmanager = {
      enable = true;
      unmanaged = [ ];
    };

    interfaces = {
      eno0 = {
      };

      wlan0 = {
      };

      br0 = {
        useDHCP = true;
        ipv4.addresses = [
          {
            address = "192.168.155.111";
            prefixLength = 21;
          }
        ];
      };
    };

    bridges = {
      br0 = {
        interfaces = [ "eno0" ]; # Replace with your actual network interface
      };
    };

    hostName = "mininixos";
    hostId = "d34d0003"; # random chars

    firewall = {
      enable = true;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
      checkReversePath = false;
      trustedInterfaces = [ "br0" ];
    };
  };
}

# vim: list nu ts=2 sw=2 et ai
