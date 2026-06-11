{ config, lib, pkgs, inputs, ... }:
let
  borgRoot     = "/data/backups/borg";
  secretsPath  = builtins.toString inputs.secrets;

  # Clients allowed to push to this repo over SSH. Each one is restricted
  # via the OpenSSH `command="borg serve --restrict-to-path …",restrict`
  # option, so the key cannot be used for anything else.
  #
  # Each client's public key is pulled at activation from the shared,
  # server-readable borg.yaml in the secrets repo. It lives there (not in the
  # per-host <host>.yaml, which also holds private material this backup server
  # must not be able to read) so mininixos can decrypt it. Rotating a client
  # key is a single-file edit to borg.yaml.
  clients = [ "lele8845ace" "lele9iyoga" ];

  secretFor   = host: "borg/clients/${host}/pubkey";
  serveCmd    = host:
    ''command="${pkgs.borgbackup}/bin/borg serve --restrict-to-path ${borgRoot}/${host}",restrict'';
in
{
  users.groups.borg = { };

  users.users.borg = {
    isSystemUser = true;
    group        = "borg";
    home         = borgRoot;
    createHome   = false;
    # Needs a real shell so sshd can exec the forced command.
    shell        = pkgs.bashInteractive;
    description  = "borg backup repo owner (restricted ssh, see borg-backup.nix)";
  };

  sops.secrets = lib.listToAttrs (map (host: {
    name  = secretFor host;
    value = {
      sopsFile = "${secretsPath}/borg.yaml";
      key      = "clients/${host}/pubkey";
    };
  }) clients);

  # Rendered at activation into /etc/ssh/authorized_keys.d/borg, which sshd
  # already reads thanks to its default AuthorizedKeysFile setting.
  sops.templates."borg-authorized-keys" = {
    path  = "/etc/ssh/authorized_keys.d/borg";
    owner = "borg";
    group = "borg";
    mode  = "0440";
    content = lib.concatStringsSep "\n" (map (host:
      "${serveCmd host} ${config.sops.placeholder.${secretFor host}}"
    ) clients) + "\n";
    restartUnits = [ "sshd.service" ];
  };

  environment.systemPackages = [ pkgs.borgbackup ];

  # /data is a post-boot LUKS-on-mdadm mount (see data-storage.nix), so
  # systemd-tmpfiles runs too early. Create/fix the repo dirs after the
  # mount is up.
  systemd.services.borg-backup-init = {
    description = "Prepare borg backup directories under ${borgRoot}";
    requires    = [ "data.mount" ];
    after       = [ "data.mount" ];
    wantedBy    = [ "multi-user.target" ];

    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -euo pipefail
      install -d -o borg -g borg -m 0750 ${borgRoot}
    '' + lib.concatStringsSep "\n" (map (host: ''
      install -d -o borg -g borg -m 0700 ${borgRoot}/${host}
    '') clients);
  };
}

# vim: set ts=2 sw=2 et ai list nu
