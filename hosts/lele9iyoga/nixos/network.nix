{
  # Rename interfaces based on MAC address to predictable names
  systemd.network.links = {
    "10-wlan0" = {
      matchConfig.MACAddress = "b0:47:e9:00:bd:9c";
      linkConfig.Name = "wlan0";
    };
  };

  networking = {
    usePredictableInterfaceNames = false; # We handle naming via systemd.network.links
    networkmanager = {
      enable = true;
      unmanaged = [ ];
    };

    bridges = {
      br0 = {
        interfaces = [ "wlan0" ];
      };
    };

    interfaces = {
      br0 = {
        useDHCP = true;
      };
    };

    hostName = "lele9iyoga";
    hostId = "d34d0007"; # random chars

    firewall = {
      enable = true;

      allowedTCPPorts = [
        24800 # default Barrier KVM software port
        51820 # wireguard
      ];
      allowedUDPPorts = [
        51820 # wireguard
      ];

      checkReversePath = false;
      trustedInterfaces = [ "br0" ];
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
