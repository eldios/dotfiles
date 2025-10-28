{
  # Rename interfaces based on MAC address to predictable names
  systemd.network.links = {
    "10-eno0" = {
      matchConfig.MACAddress = "10:ff:e0:3d:a0:7d";
      linkConfig.Name = "eno0";
    };
    "10-wlan0" = {
      matchConfig.MACAddress = "e8:47:3a:e7:f6:59";
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
        interfaces = [ "eno0" ];
      };
    };

    interfaces = {
      br0 = {
        useDHCP = true;
      };
    };

    hostName = "lele8845ace";
    hostId = "d34d0008"; # random chars

    firewall = {
      enable = true;

      allowedTCPPorts = [
        24800 # default Barrier KVM software port
      ];

      checkReversePath = false;
      trustedInterfaces = [ "br0" ];
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
