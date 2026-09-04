# Caching dnsmasq resolver with tailnet split-DNS and drop-in host entries.
{
  den.aspects.dns.nixos.imports = [./_dns.nix];
}
