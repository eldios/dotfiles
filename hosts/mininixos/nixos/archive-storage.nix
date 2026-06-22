# 2x 10TB WD: BTRFS raid1 su due container LUKS -> /archive (backup 2 livello)
#
# I due dischi condividono lo STESSO header LUKS clonato (UUID 53bf86ec...) e lo
# stesso PARTUUID: vanno referenziati by-id (seriale per-disco), MAI by-UUID.
# /root/data.key (sul root cifrato) sblocca entrambi, come gli altri secondari.

{ ... }:

{
  environment.etc."crypttab".text = ''
    Karchive   /dev/disk/by-id/ata-WDC_WD102KFBX-68M95N0_VCG9HBKM-part1 /root/data.key luks,nofail
    KarchiveB1 /dev/disk/by-id/ata-WDC_WD102KFBX-68M95N0_VCG6MLWN-part1 /root/data.key luks,nofail
  '';

  fileSystems."/archive" = {
    device = "/dev/mapper/Karchive";
    fsType = "btrfs";
    options = [
      "subvol=/"
      "compress=zstd:3"
      "noatime"
      "nodiratime"
      # space_cache v2: con v1 il mount di questo raid1 quasi pieno sfora i 90s
      "space_cache=v2"
      "nofail"
      # 90s di default non bastano (10TB meccanici, ~98% pieno): senza questo,
      # nofail lascia /archive smontato in silenzio dopo un mount lento al boot
      "x-systemd.mount-timeout=300"
      # raid1 multi-device: elenca entrambe le meta cosi il mount assembla
      # senza dipendere da un btrfs device scan precedente
      "device=/dev/mapper/Karchive"
      "device=/dev/mapper/KarchiveB1"
      "x-systemd.requires=systemd-cryptsetup@Karchive.service"
      "x-systemd.requires=systemd-cryptsetup@KarchiveB1.service"
    ];
  };

  # Scrub settimanale: su raid1 lo scrub RIPARA davvero dal mirror
  services.btrfs.autoScrub.fileSystems = [ "/archive" ];
}

# vim: set ts=2 sw=2 et ai list nu
