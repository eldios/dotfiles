{ ... }:
# Caching DNS resolver on every host.
#
# Chosen over systemd-resolved and unbound for one reason: only dnsmasq lets you
# add a hostname by dropping a file into a directory. It watches hostsdir with
# inotify and picks the change up in under a second, with no reload and no
# rebuild, which is what makes throwaway machines bearable.
#
# Importing this on a host requires `sudo tailscale set --accept-dns=false`
# once, otherwise tailscaled and dnsmasq both rewrite /etc/resolv.conf. It
# cannot be declared here: services.tailscale.extraUpFlags only takes effect
# through tailscaled-autoconnect, which never runs without an authKeyFile.
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

      # Split-DNS for the tailnet, so MagicDNS names resolve without handing
      # /etc/resolv.conf to systemd-resolved. Matching the whole ts.net TLD
      # avoids naming this tailnet and survives a rename; MagicDNS only ever
      # answers for our own tailnet anyway. The second entry is a wildcard over
      # the 100.x reverse space, so `dig -x` on a tailnet IP works.
      server = [
        "/ts.net/100.100.100.100"
        "/100.in-addr.arpa/100.100.100.100"
      ];

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

  # Short names for tailnet-only nodes. A search domain cannot be a wildcard the
  # way the ts.net forward above is, so the tailnet is spelled out here.
  # `_append` and not networking.search: the latter goes in through resolvconf's
  # static record at metric 1, which would put the tailnet ahead of the
  # DHCP-supplied domains and send `ssh mininixos` over the tailnet instead of
  # the LAN. See search_domains vs search_domains_append in resolvconf.conf(5).
  networking.resolvconf.extraConfig = ''
    search_domains_append='caracal-great.ts.net'
  '';

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
