{ ... }:
{
  networking = {
    networkmanager.enable = true;

    dhcpcd.enable = true;

    interfaces = { };

    hostName = "sox1x";
    hostId   = "d34db14f"; # random chars

    firewall.enable = true;
  };
}

# vim: set ts=2 sw=2 et ai list nu
