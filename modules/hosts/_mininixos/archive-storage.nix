# Two 10TB WD disks: btrfs raid1 over two LUKS containers, mounted on
# /archive as the second backup tier.
#
# The two disks carry the SAME cloned LUKS header (UUID 53bf86ec...) and the
# same PARTUUID, so they must be referenced by-id (per-disk serial), never
# by UUID. /root/data.key on the encrypted root unlocks both, like the other
# secondary disks.
{...}: {
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
      # space_cache v2: with v1 the mount of this nearly full raid1 exceeds 90s
      "space_cache=v2"
      "nofail"
      # The default 90s is not enough (10TB spinning disks, ~98% full): without
      # this, nofail silently leaves /archive unmounted after a slow boot mount
      "x-systemd.mount-timeout=300"
      # Multi-device raid1: list both members so the mount assembles without
      # depending on an earlier btrfs device scan
      "device=/dev/mapper/Karchive"
      "device=/dev/mapper/KarchiveB1"
      "x-systemd.requires=systemd-cryptsetup@Karchive.service"
      "x-systemd.requires=systemd-cryptsetup@KarchiveB1.service"
    ];
  };

  # Weekly scrub: on raid1 the scrub really repairs from the mirror
  services.btrfs.autoScrub.fileSystems = ["/archive"];
}
# vim: set ts=2 sw=2 et ai list nu

