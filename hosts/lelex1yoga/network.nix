{ ... }:
{
  networking = {
    networkmanager.enable = true;

    dhcpcd.enable = true;

    interfaces = {
      #eno1 = {
      #  useDHCP = true;
      #  #ipv4.addresses = [{
      #  #  address = "192.168.155.111";
      #  #  prefixLength = 21;
      #  #}];
      #};
    };

    #defaultGateway = "192.168.1.1";
    #nameservers = [ "1.1.1.1" "8.8.8.8" ];

    hostName = "lelex1yoga";
    hostId   = "d34db00f"; # random chars

    firewall = {
      enable = true;
      # allowedTCPPorts = [ ... ];
      # allowedUDPPorts = [ ... ];
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
