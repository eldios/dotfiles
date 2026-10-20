# Nightly integrity check of the ncps NAR store. ncps serves a NAR file as it
# is on disk, so a file cut short (for example by a crash before the write
# reached the disk) is handed out as is. Removing it is the repair: ncps
# treats the database row as a placeholder and fetches the NAR again from
# upstream on the next request.
{
  config,
  pkgs,
  ...
}: let
  check = pkgs.writeShellApplication {
    name = "nix-cache-check";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.sqlite
      pkgs.jq
      config.virtualisation.docker.package
    ];
    text = ''
      db=/srv/nix-cache/var/ncps/db/db.sqlite
      store=/srv/nix-cache/store/nar

      # Whole-file NARs only: chunked ones (total_chunks > 0) have no file.
      # ncps names zstd files .zst and keeps every other compression as is.
      query="select hash,
               case compression when 'zstd' then '.zst' when ''' then ''' else '.' || compression end,
               file_size
             from nar_files where total_chunks = 0"

      removed=0
      while read -r hash ext size; do
        file="$store/''${hash:0:1}/''${hash:0:2}/$hash.nar$ext"
        [[ -f $file ]] || continue
        actual=$(stat -c %s "$file")
        if [[ $actual != "$size" ]]; then
          echo "removing $file: $actual bytes, the database expects $size"
          rm -f -- "$file"
          removed=$((removed + 1))
        fi
      done < <(sqlite3 -readonly -separator ' ' "file:$db?mode=ro" "$query")

      echo "removed $removed NAR files"
      if ((removed > 0)); then
        # apprise is reachable only on the proxy network, hence from inside
        # its own container.
        body="nix-cache: removed $removed NAR files whose size did not match the ncps database; ncps fetches them again on the next request (journalctl -u nix-cache-check)"
        jq -nc --arg body "$body" '{type: "warning", body: $body}' |
          docker exec -i apprise curl -sSf -X POST -H 'Content-Type: application/json' \
            --data-binary @- http://localhost:8000/notify/infra
      fi
    '';
  };
in {
  systemd.services.nix-cache-check = {
    description = "Remove ncps NAR files whose size does not match the database";
    after = ["docker.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${check}/bin/nix-cache-check";
    };
  };
  systemd.timers.nix-cache-check = {
    wantedBy = ["timers.target"];
    # After the ncps LRU run (04:00) and before the nightly prebuild (06:00).
    timerConfig.OnCalendar = "*-*-* 05:00:00";
  };
}
# vim: set ts=2 sw=2 et ai list nu

