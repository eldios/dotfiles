{ pkgs, ... }:
{
  # Rename interfaces based on MAC address to predictable names
  systemd.network.links = {
    "10-eno0" = {
      matchConfig.MACAddress = "58:47:ca:7d:39:8e";
      linkConfig.Name = "eno0";
    };
    "10-wlan0" = {
      matchConfig.MACAddress = "24:eb:16:22:86:c5";
      linkConfig.Name = "wlan0";
    };
  };

  networking = {
    usePredictableInterfaceNames = false; # We handle naming via systemd.network.links
    networkmanager = {
      enable = true;
      unmanaged = [ "eno0" "eno0.50" "br0" "br50" ];
      # Pin public resolvers: MagicDNS here is flaky and the UniFi gateway
      # doesn't serve DNS, so without these the box can't resolve anything.
      insertNameservers = [ "1.1.1.1" "9.9.9.9" ];
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
      allowedTCPPorts = [
        8095 # Music Assistant web UI (raggiunto da traefik su docker bridge)
      ];
      checkReversePath = false;
      trustedInterfaces = [ "br0" "br50" ];
    };
  };

  # eno0 is a pure br0 slave. The initrd clevis network (see clevis-unlock.nix)
  # assigns this host's static LAN IP to eno0 to reach Tang at boot; because NM
  # leaves eno0/br0 unmanaged, the scripted stage-2 network never strips it, so
  # the address lingers on eno0 and shadows br0's LAN route — Tang and the LAN
  # become unreachable. Drop eno0's stray IPv4 once its address unit has run.
  systemd.services.flush-eno0-stray-addr = {
    after = [ "network-addresses-eno0.service" ];
    before = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "-${pkgs.iproute2}/bin/ip -4 addr flush dev eno0";
    };
  };
}

# vim: list nu ts=2 sw=2 et ai
