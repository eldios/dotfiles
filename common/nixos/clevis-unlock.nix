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
{ config, inputs, lib, pkgs, ... }:
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
  # a hung Tang fetch (peer offline) blocks the Yubikey and passphrase prompts
  # until it gives up — which was a 10-minute stall by default. 120s, not less:
  # the switch holds the port in STP learning for ~15-30s after the initrd
  # brings the link up, and a 30s cap killed the fetch right as Tang answered
  # (the service stop also unmounts the ramfs, discarding the fetched key).
  boot.initrd.systemd.services."cryptsetup-clevis-${luksName}".serviceConfig.TimeoutStartSec = 120;

  # Yubikey FIDO2 = manual fallback after Clevis. No-PIN (touch-only) tokens are
  # detected in initrd via boot.initrd.systemd.fido2 (default-on; ships
  # 60-fido-id.rules / fido_id, which fixed nixpkgs#265367). First match wins:
  # a good Clevis keyfile unlocks without ever touching the token.
  # tries=0: keep cycling Yubikey/passphrase prompts forever instead of failing
  # into emergency after 3 unanswered attempts — a remote box must sit at the
  # prompt waiting for a human, not collapse. (Password query timeout is already
  # indefinite by default; the FIDO2 token wait stays at its 30s default.)
  boot.initrd.luks.devices.${luksName}.crypttabExtraOpts = [ "fido2-device=auto" "tries=0" ];

  # Let the initrd emergency shell actually start (default refuses: root is
  # locked, so a failed unlock leaves a dead console). Pre-unlock the disk is
  # still encrypted, so a console shell exposes nothing the attacker doesn't
  # already have; a usable rescue shell is what lets us debug failed unlocks.
  boot.initrd.systemd.emergencyAccess = true;

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

  # The initrd address above leaks into stage 2: eno0 is a pure br0 slave there,
  # but nothing strips the leftover IP, which then shadows br0's LAN route — the
  # kernel routes replies out the raw slave, ARP never resolves, and peer Tang
  # traffic dies silently (this broke clevis on BOTH hosts, in both directions).
  # Flush eno0's IPv4 once stage-2 networking has set up the bridge.
  systemd.services.flush-eno0-stray-addr = {
    after = [ "network-addresses-eno0.service" "br0-netdev.service" ];
    before = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "-${pkgs.iproute2}/bin/ip -4 addr flush dev eno0";
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu
