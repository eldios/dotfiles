# Borg backup target: a restricted `borg serve` account the client hosts
# push to over ssh, with one repository directory per client.
{
  den.aspects.backup-server.nixos.imports = [./_backup-server.nix];
}
