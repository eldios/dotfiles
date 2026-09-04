# What every host is: the nix daemon and its policies, the always-on
# services (ssh, fail2ban, tailscale, smartd, fstrim), the base package set,
# the root account, and the boot and sleep defaults hosts build on.
{
  den.aspects.base.nixos.imports = [
    ./_base/system.nix
    ./_base/boot.nix
    ./_base/suspend.nix
    ./_base/users.nix
  ];
}
