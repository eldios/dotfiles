# PipeWire tuned for the USB DACs on the desk: high sample rates, no device
# suspension, realtime scheduling.
{
  den.aspects.audio = {
    nixos.imports = [./_audio/audio.nix];
  };
}
