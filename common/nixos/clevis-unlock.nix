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
# the secrets input (no-op before `nix flake update secrets`).
#
# Networking is STATIC in initrd (eno0 reuses br0's static address). DHCP/DNS
# proved too volatile — leases and `.lan` records drift, so the boot couldn't
# reliably reach the peer Tang. The JWE targets are the peers' static IPs.
#
# Fallbacks if Tang is unreachable (blackout, off-network): the Yubikey FIDO2
# keyslots (crypttabExtraOpts below) and the passphrase (keyslot 0) remain.
{ config, inputs, lib, ... }:
let
  host = config.networking.hostName;
  jweFile = "${inputs.secrets}/clevis/${host}.jwe";
  # Root LUKS mapper name per host. Hardcoded (not read from
  # boot.initrd.luks.devices) to avoid a recursion: this module also writes
  # crypttabExtraOpts into that same option.
  luksName = {
    mininixos = "M";
    lele8845ace = "data";
  }.${host};
  br0addr = lib.head config.networking.interfaces.br0.ipv4.addresses;
in
lib.mkIf (builtins.pathExists jweFile) {
  boot.initrd.clevis = {
    enable = true;
    useTang = true;
    devices.${luksName}.secretFile = jweFile;
  };

  # Cap the Clevis attempt. cryptsetup@<dev> is ordered *after* this service, so
  # a hung Tang fetch (peer offline / flaky LAN) blocks the Yubikey and
  # passphrase prompts until it gives up — which is the 10-minute stall we hit.
  # 30s is ample when Tang is reachable; past that we want the manual fallbacks.
  boot.initrd.systemd.services."cryptsetup-clevis-${luksName}".serviceConfig.TimeoutStartSec = 30;

  # Yubikey FIDO2 = manual fallback after Clevis. token-timeout=300 gives a 5-min
  # window to insert and touch the key (e.g. someone walking up to the box) before
  # falling through to the passphrase. No-PIN (touch-only) tokens are detected in
  # initrd thanks to boot.initrd.systemd.fido2 (default-on), which ships the
  # 60-fido-id.rules udev rule that fixed nixpkgs#265367. Order: Clevis -> Yubikey -> passphrase.
  boot.initrd.luks.devices.${luksName}.crypttabExtraOpts = [ "fido2-device=auto" "token-timeout=300" ];

  # initrd networking: static IP on eno0 (the bridge br0 only exists in stage 2).
  boot.initrd.availableKernelModules = [ "r8169" ];
  boot.initrd.systemd.network = {
    enable = true;
    wait-online = {
      enable = true;
      anyInterface = true;
    };
    networks."10-eno0" = {
      matchConfig.Name = "eno0";
      address = [ "${br0addr.address}/${toString br0addr.prefixLength}" ];
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
