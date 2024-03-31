{ index, ...}:
{
  networking = {
    networkmanager.enable = true;

    interfaces = {
      eth0.useDHCP = true;

      eth1 = {
        ipv4 = {
          routes = [
            {
              address = "10.1.0.1";
              prefixLength = 32;
              options = {
                src = "10.1.0.${builtins.toString (builtins.add index 1)}";
                mtu = "1450";
                metric = "1010";
              };
            }
            {
              address = "10.1.0.0";
              prefixLength = 16;
              via = "10.1.0.1";
              options = {
                src = "10.1.0.${builtins.toString (builtins.add index 1)}";
                mtu = "1450";
                metric = "1010";
              };
            }
          ];
          addresses = [
            {
              address = "10.1.0.${builtins.toString (builtins.add index 1)}";
              prefixLength = 32;
            }
          ];
        };
      };
    };

    hostName = "fsn-c${builtins.toString index}";
    hostId   = "d34d010${builtins.toString index}"; # random chars

    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        6643
      ];
      extraInputRules = [
        "ip4 saddr { 10.1.0.0/24  } accept" # private network
        "ip4 saddr { 10.42.0.0/16 } accept" # pods
        "ip4 saddr { 10.43.0.0/16 } accept" # services

        "ip4 saddr { 116.202.108.212 } accept" # fsn-c1
        "ip4 saddr { 159.69.248.126  } accept" # fsn-c2
        "ip4 saddr { 138.201.190.214 } accept" # fsn-c3

        "ip4 iifname tailscale0 accept" # allows Tailscale interface
      ];
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
