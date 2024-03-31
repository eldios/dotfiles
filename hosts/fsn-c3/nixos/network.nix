{
  networking = {
    networkmanager.enable = true;

    dhcpcd.enable = true;

    interfaces = {
      eth0.useDHCP = true;
    };

    hostName = "fsn-c3";
    hostId   = "d34d0103"; # random chars

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        6643
      ];
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
