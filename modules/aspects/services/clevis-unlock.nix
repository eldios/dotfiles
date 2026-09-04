# Clevis network-bound LUKS unlock in stage 1. Only for hosts that declare
# `luksRoot` in hosts.nix: the module reads it for the mapper name.
{
  den.aspects.clevis-unlock.nixos = import ./_clevis-unlock.nix;
}
