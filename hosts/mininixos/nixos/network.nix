{
  networking = {
    dhcpcd.enable = true;

    interfaces = {
      eno1 = {
        useDHCP = true;
        ipv4.addresses = [{
          address = "192.168.155.111";
          prefixLength = 21;
        }];
      };
    };

    #defaultGateway = "192.168.1.1";
    #nameservers = [ "1.1.1.1" "8.8.8.8" ];

    hostName = "mininixos";
    hostId   = "d34d0003"; # random chars

    firewall = {
      enable = false;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
  };
}

# vim: list nu ts=2 sw=2 et ai
