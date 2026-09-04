# Host secrets: sops-nix keyed on the host ssh key, the shared secrets file
# as default source, and the secrets every host declares.
{inputs, ...}: {
  den.aspects.sops.nixos.imports = [
    inputs.sops-nix.nixosModules.sops
    ./_sops.nix
  ];
}
