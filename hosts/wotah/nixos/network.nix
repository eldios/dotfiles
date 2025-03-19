{ lib, ... }:
{
  networking = {
    networkmanager.enable = true;

    useDHCP = lib.mkDefault true;
    dhcpcd.enable = true;

    interfaces = { };

    hostName = "wotah";
    hostId = "d34d0009"; # random chars

    firewall = {
      enable = true;

      allowedTCPPorts = [
        22
        80
        443
      ];
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
