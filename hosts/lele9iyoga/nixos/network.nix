{ lib, ...}:
{
  networking = {
    networkmanager.enable = true;

    useDHCP = lib.mkDefault true;
    dhcpcd.enable = true;

    interfaces = { };

    hostName = "lele9iyoga";
    hostId   = "d34d0007"; # random chars

    firewall = {
      enable = true;

      allowedTCPPorts = [
        24800 # default Barrier KVM software port
      ];
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
