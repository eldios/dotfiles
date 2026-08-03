{ ... }:
# Caching DNS resolver on every host.
#
# Chosen over systemd-resolved and unbound for one reason: only dnsmasq lets you
# add a hostname by dropping a file into a directory. It watches hostsdir with
# inotify and picks the change up in under a second, with no reload and no
# rebuild, which is what makes throwaway machines bearable.
{
  services.dnsmasq = {
    enable = true;
    # Points /etc/resolv.conf at 127.0.0.1 and keeps the real upstream list in
    # /etc/dnsmasq-resolv.conf.
    resolveLocalQueries = true;
    alwaysKeepRunning = true;

    settings = {
      # libvirt runs its own dnsmasq on virbr0:53, so never bind the wildcard.
      # bind-dynamic also copes with docker0 appearing after this service starts.
      listen-address = [ "127.0.0.1" "172.17.0.1" ];
      bind-dynamic = true;

      # No `no-resolv` on purpose: upstream comes from resolvconf, so
      # DHCP/VPN-provided servers survive. That keeps LAN names resolvable and
      # keeps roaming laptops working on networks that mandate their resolver.

      # Ad-hoc hosts: one file per entry, picked up without a rebuild.
      hostsdir = "/var/lib/dnsmasq/hosts.d";
      local-ttl = 60;

      cache-size = 10000; # dnsmasq default is 150
      # Default is 150 concurrent queries. Matrix federation on mininixos talks
      # to ~6k destinations and its SRV bursts exhaust that, after which
      # federation fails with "Maximum number of concurrent DNS queries".
      dns-forward-max = 1500;
      neg-ttl = 60;
      min-cache-ttl = 60;

      domain-needed = true;
      bogus-priv = true;
      log-async = 25;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/dnsmasq/hosts.d 0755 root root -"
  ];

  # Do NOT set virtualisation.docker.daemon.settings.dns. Containers on
  # user-defined (compose) networks reach the host's 127.0.0.1 through Docker's
  # embedded resolver, which dials it inside the host namespace. Pinning a
  # bridge gateway instead points every container at an address only the default
  # bridge can route to, and breaks DNS on every other network.
  networking.firewall.interfaces."docker0" = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
