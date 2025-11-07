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
      unmanaged = [ "eno0" "eno0.50" "br0" "br50" ];
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

      # VLAN 50 interface for NAS network
      "eno0.50" = {
        # No IP needed - bridged to br50
      };

      # Bridge for VLAN 50 (NAS network)
      br50 = {
        # No IP needed on host - VMs will use this bridge
      };
    };

    # VLAN interfaces
    vlans = {
      "eno0.50" = {
        id = 50;
        interface = "eno0";
      };
    };

    bridges = {
      br0 = {
        interfaces = [ "eno0" ]; # Main network (untagged)
      };
      br50 = {
        interfaces = [ "eno0.50" ]; # VLAN 50 (NAS network)
      };
    };

    hostName = "mininixos";
    hostId = "d34d0003"; # random chars

    firewall = {
      enable = true;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
      checkReversePath = false;
      trustedInterfaces = [ "br0" "br50" ];
    };
  };
}

# vim: list nu ts=2 sw=2 et ai
