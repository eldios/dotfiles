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

    # WiFi-only host: a managed-mode wlan0 CANNOT be enslaved to a bridge
    # (kernel: "Device does not allow enslaving to a bridge"), unlike the
    # ethernet hosts where br0 bridges eno0 onto the LAN. Here br0 is a NAT
    # bridge with NO physical uplink: libvirt VMs stay attached to it
    # (<source bridge='br0'/>) and reach the outside via NAT out of wlan0.
    bridges.br0.interfaces = [ ];
    interfaces.br0.ipv4.addresses = [
      { address = "192.168.100.1"; prefixLength = 24; }
    ];

    nat = {
      enable = true;
      externalInterface = "wlan0";
      internalInterfaces = [ "br0" ];
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
      trustedInterfaces = [ "br0" ]; # VM-facing NAT bridge (DHCP/DNS/guests)
    };
  };

  # DHCP for the VMs on br0, served by the same dnsmasq that caches for the
  # host. Everything else, including the cache and the listen addresses, comes
  # from common/nixos/dns.nix. No bind-interfaces here: that module uses
  # bind-dynamic, and dnsmasq rejects the two together.
  services.dnsmasq.settings = {
    interface = "br0";
    dhcp-range = [ "192.168.100.50,192.168.100.200,24h" ];
    dhcp-option = [
      "option:router,192.168.100.1"
      "option:dns-server,192.168.100.1"
    ];
  };

  # DHCP wants the bridge addressed before it starts handing out leases.
  systemd.services.dnsmasq = {
    after = [ "network-addresses-br0.service" "br0-netdev.service" ];
    wants = [ "network-addresses-br0.service" ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
