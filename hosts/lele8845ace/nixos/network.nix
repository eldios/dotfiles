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

  # Required by networkmanager.dns = "systemd-resolved" below: resolved owns
  # /etc/resolv.conf (stub 127.0.0.53) and routes *.ts.net to Tailscale.
  services.resolved.enable = true;

  networking = {
    usePredictableInterfaceNames = false; # We handle naming via systemd.network.links
    networkmanager = {
      enable = true;
      # eno0/br0 are owned by the scripted bridge below. Left to NetworkManager
      # it claims eno0 with a standalone "Wired connection 1", leaving br0
      # slave-less and DOWN (no LAN/.40, no VM bridging). wlan0 stays NM-managed.
      unmanaged = [
        "eno0"
        "br0"
      ];
      # Hand DNS to systemd-resolved so the mesh VPN client can do split-DNS
      # cleanly. With NM's default backend, NM and the VPN daemon both write
      # via openresolv, which clobbers the VPN resolver and breaks peer /
      # internal-domain resolution.
      dns = "systemd-resolved";
      # Pin public resolvers: the UniFi gateway handed out via DHCP does not
      # serve DNS. Under resolved these are the per-link upstream for the
      # default route; the VPN routes its own search domain to its resolver.
      insertNameservers = [
        "1.1.1.1"
        "9.9.9.9"
      ];
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
