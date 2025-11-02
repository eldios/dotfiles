{
  networking = {
    dhcpcd.enable = true;
    usePredictableInterfaceNames = true;

    interfaces = {
      eno0 = {
        macAddress = "58:47:ca:7d:39:8e";
      };

      wlan0 = {
        macAddress = "58:47:ca:7d:39:8e";
      };

      br0 = {
        useDHCP = true;
      };
    };

    bridges = {
      br0 = {
        interfaces = [ "eno0" ]; # Replace with your actual network interface
      };
    };

    defaultGateway = "192.168.152.1";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

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
