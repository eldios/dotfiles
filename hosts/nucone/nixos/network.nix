{ ... }:
{
  networking = {
    networkmanager.enable = true;

    dhcpcd.enable = true;

    interfaces = { };

    hostName = "nucone";
    hostId   = "d34d0002"; # random chars

    firewall.enable = true;
  };
}

# vim: set ts=2 sw=2 et ai list nu
