{lib, ...}: {
  # Public fallback resolvers, kept because DNS on the LAN gateways has proven
  # unreliable here. Last in the list: with strict-order (dns aspect) they are
  # asked only when the LAN servers do not answer, so local zones keep
  # resolving.
  services.dnsmasq.settings.server = lib.mkAfter ["1.1.1.1" "9.9.9.9"];

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
    # USB dongle on VLAN 13. The kernel hands out ethN in probe order, so a
    # second USB NIC can take eth0 first; the name stays outside that space.
    "10-lan13" = {
      matchConfig.MACAddress = "6c:1f:f7:71:d8:9f";
      linkConfig.Name = "lan13";
    };
  };

  # br13-netdev binds to the dongle, so unplugging it tears br13 down, but the
  # generated unit is only wanted by network.target: nothing brings br13 back
  # when the dongle shows up late or is plugged in again. Its start script also
  # re-enslaves the taps of running guests, which puts bsdino back on br13.
  systemd.services.br13-netdev.wantedBy = ["sys-subsystem-net-devices-lan13.device"];

  networking = {
    # With the default lease-everything, the USB dongle on the isolation VLAN
    # wins the default route on metric. Only br0 asks for a lease, declared below.
    useDHCP = false;

    usePredictableInterfaceNames = false; # We handle naming via systemd.network.links
    networkmanager = {
      enable = true;
      # type:ethernet keeps any wired NIC not declared here (a dock, a USB
      # adapter) without a lease and a default route that would beat br0.
      unmanaged = ["type:ethernet" "eno0" "eno0.50" "br0" "br50" "lan13" "br13"];
      # No insertNameservers here: it lands ahead of 127.0.0.1 in resolv.conf,
      # so every host query skips the local cache. The public resolvers it used
      # to pin are dnsmasq upstreams instead, declared at the top of this file.
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

      # USB dongle wired to a UDM port on VLAN 13 (isolation network)
      lan13 = {
        # No IP: the host stays off the isolation network, bsdino reaches it
        # through br13 and is routed by the gateway
      };

      br13 = {
        # No IP needed on host - bsdino uses this bridge
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
        interfaces = ["eno0"]; # Main network (untagged)
      };
      br50 = {
        interfaces = ["eno0.50"]; # VLAN 50 (NAS network)
      };
      br13 = {
        interfaces = ["lan13"]; # VLAN 13 (isolation network, untagged on the dongle)
      };
    };

    hostId = "d34d0003"; # random chars

    firewall = {
      enable = true;
      allowedTCPPorts = [
        8095 # Music Assistant web UI, used by traefik
        8188 # ComfyUI firwall access
        8971 # Frigate authenticated UI, reached by traefik
        9100 # node-exporter, used by prometheus
        11434 # ollama firewall access
      ];
      checkReversePath = false;
      trustedInterfaces = ["br0" "br50"];
    };
  };
}
# vim: list nu ts=2 sw=2 et ai

