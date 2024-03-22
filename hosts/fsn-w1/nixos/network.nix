{
  networking = {
    networkmanager.enable = true;

    dhcpcd.enable = true;

    interfaces = { };

    hostName = "fsn-w1";
    hostId   = "d34d0006"; # random chars

    firewall.enable = true;
  };
}

# vim: set ts=2 sw=2 et ai list nu
