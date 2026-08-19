# Overlay: vm-curator
#
# TUI for desktop QEMU/KVM virtual machines (3D acceleration, no libvirt).
# Packaged by upstream's own flake; the input follows nixpkgs-unstable, so it
# builds against the same package set as the rest of this config.
# Not in nixpkgs yet: drop this once https://github.com/NixOS/nixpkgs/pull/490323 lands.
{vm-curator, ...}: self: super: {
  vm-curator = vm-curator.packages.${super.stdenv.hostPlatform.system}.default;
}
# vim: set ts=2 sw=2 et ai list nu
