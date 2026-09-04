# Tang key-exchange endpoint on the always-on LAN hosts, so each can unlock
# the other's root LUKS at boot.
{
  den.aspects.tang-server.nixos.imports = [./_tang-server.nix];
}
