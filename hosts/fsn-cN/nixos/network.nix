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
      trustedInterfaces = [
        "eth1"
        "tailscale0"
      ];
      allowedTCPPorts = [
        22
        80
        443
        6443
      ];
      extraInputRules = ""                      +
        "tcp dport 22 accept\n"                 +
        "tcp dport 80 accept\n"                 +
        "tcp dport 443 accept\n"                +
        "tcp dport 6443 accept\n"               +

        "ip saddr { 10.1.0.0/24  } accept\n"    + # private network
        "ip saddr { 10.42.0.0/16 } accept\n"    + # pods
        "ip saddr { 10.43.0.0/16 } accept\n"    + # services

        "ip saddr { 116.202.108.212 } accept\n" + # fsn-c1
        "ip saddr { 159.69.248.126  } accept\n" + # fsn-c2
        "ip saddr { 138.201.190.214 } accept\n" + # fsn-c3

        "ip iifname eth1 accept\n"              + # allows private network interface
        "ip iifname tailscale0 accept\n"        + # allows Tailscale interface
        "";
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
