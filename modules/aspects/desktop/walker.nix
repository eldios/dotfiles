# Walker launcher and its elephant data daemon as system-level user
# services, for hosts whose session starts them at login rather than
# through desktop-switch.
{
  den.aspects.walker = {
    nixos.imports = [./_walker/walker.nix];
  };
}
