# The ncps binary cache: substituters and trusted keys for every host, plus
# the per-host push key that signs and uploads locally built paths.
{
  den.aspects.nix-cache.nixos.imports = [./_nix-cache.nix];
}
