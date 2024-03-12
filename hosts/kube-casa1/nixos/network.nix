{ ... }:
{
  networking = {
    networkmanager.enable = true;

    dhcpcd.enable = true;

    interfaces = { };

    hostName = "kube-casa1";
    hostId   = "d34d0005"; # random chars

    firewall.enable = true;
  };
}

# vim: set ts=2 sw=2 et ai list nu
