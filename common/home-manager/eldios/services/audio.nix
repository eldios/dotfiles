{ ... }:
{
  # Audio device rules and the PipeWire clock live in common/nixos/audio.nix
  # (single source of truth). Do NOT add per-user WirePlumber rules here: a
  # duplicate copy conflicts with the system rules (priority + clock.rate
  # clashes) and breaks the Bifrost DAC.
}
# EOF
# vim: set ts=2 sw=2 et ai list nu
