# Tang server — key-exchange endpoint for Clevis network-bound LUKS unlock.
#
# Enabled on the always-on home hosts (mininixos, lele8845ace) so each can
# auto-unlock the other over the LAN at boot. Restricted to the local subnet:
# the JWE is useless without a reachable Tang, but defence in depth is cheap.
{ ... }:
{
  services.tang = {
    enable = true;
    listenStream = [ "7654" ];
    ipAddressAllow = [ "192.168.152.0/21" ];
  };

  # Tang must be reachable on the LAN regardless of which interface holds the
  # host IP. Relying on the bridge being a trusted firewall interface is
  # fragile — when the static IP lands on the raw NIC instead, peers' unlock
  # requests get dropped. Open the port; ipAddressAllow above is the real ACL.
  networking.firewall.allowedTCPPorts = [ 7654 ];
}
# vim: set ts=2 sw=2 et ai list nu
