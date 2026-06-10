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
}
# vim: set ts=2 sw=2 et ai list nu
