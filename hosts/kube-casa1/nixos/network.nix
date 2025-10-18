{
  systemd.network.links."10-eth0" = {
    matchConfig.PermanentMACAddress = "68:1d:ef:40:80:d1";
    linkConfig.Name = "eth0";
  };

  networking = {
    networkmanager.enable = true;

    dhcpcd.enable = true;

    bridges = {
      br0 = {
        interfaces = [ "eth0" ];
      };
    };

    hostName = "kube-casa1";
    hostId = "d34d0009"; # random chars

    firewall.enable = true;
  };
}

# vim: set ts=2 sw=2 et ai list nu
