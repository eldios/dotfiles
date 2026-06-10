# Clevis network-bound LUKS auto-unlock (systemd stage 1).
#
# Each host's root LUKS is unlocked at boot by fetching a Shamir-split key
# from the OTHER host's Tang server over the LAN (see [[tang-server.nix]]).
# The per-host JWE (the wrapped keyslot passphrase) lives in the private
# secrets repo, in the clear by design: it is useless without a reachable
# Tang, and the initrd needs it at build time (before sops exists).
#
# Generic: resolves the JWE by hostname and the LUKS device name from the
# host's own initrd.luks config. Self-activates only once the JWE exists in
# the secrets input (so it is a no-op before `nix flake update secrets`).
#
# Fallbacks if Tang is unreachable (blackout, off-network): the passphrase
# (keyslot 0) and the Yubikey FIDO2 keyslots remain.
{ config, inputs, lib, ... }:
let
  host = config.networking.hostName;
  jweFile = "${inputs.secrets}/clevis/${host}.jwe";
  luksDevices = lib.attrNames config.boot.initrd.luks.devices;
in
lib.mkIf (builtins.pathExists jweFile && luksDevices != [ ]) {
  boot.initrd.clevis = {
    enable = true;
    useTang = true;
    devices.${lib.head luksDevices}.secretFile = jweFile;
  };

  # initrd networking so Clevis can reach the peer Tang. eno0 via DHCP — the
  # UniFi reservation pins each host's address; the bridge br0 only exists in
  # stage 2, so in initrd we talk to the raw NIC.
  boot.initrd.availableKernelModules = [ "r8169" ];
  boot.initrd.systemd.network = {
    enable = true;
    networks."10-eno0" = {
      matchConfig.Name = "eno0";
      networkConfig.DHCP = "ipv4";
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
