{ ... }:
{
  # Audio device rules and the PipeWire graph clock are centralized in
  # common/nixos/audio.nix as the single source of truth. Keeping a second
  # copy here caused WirePlumber rule conflicts (duplicate Bifrost rules with
  # a different priority, a hard-pinned 192 kHz rate, and a clashing
  # default.clock.rate). No per-user audio overrides are needed.
}
# EOF
# vim: set ts=2 sw=2 et ai list nu
