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
      # eno0/br0 are owned by the scripted bridge below. Left to NetworkManager
      # it claims eno0 with a standalone "Wired connection 1", leaving br0
      # slave-less and DOWN (no LAN/.40, no VM bridging). wlan0 stays NM-managed.
      unmanaged = [ "eno0" "br0" ];
    };

    bridges = {
      br0 = {
        interfaces = [ "eno0" ];
      };
    };

    interfaces = {
      br0 = {
        useDHCP = true;
        # Static IP: stable address for Clevis/Tang (also reused in initrd).
        ipv4.addresses = [
          {
            address = "192.168.155.40";
            prefixLength = 21;
          }
        ];
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
