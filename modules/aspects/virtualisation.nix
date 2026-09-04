# Docker with the Kata runtime, containerd, libvirt with swtpm, and the
# Kubernetes tooling used against local and remote clusters.
{
  den.aspects.virtualisation.nixos.imports = [./_virtualisation.nix];
}
