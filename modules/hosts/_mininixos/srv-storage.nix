# 2TB NVMe secondary disk: one LUKS container with a btrfs volume whose
# @docker and @containers subvolumes back /srv/docker and /srv/containers.
{...}: {
  # Post-boot LUKS decryption via crypttab. The key file sits on the encrypted
  # root, so the disk opens on its own once root is unlocked.
  environment.etc."crypttab".text = ''
    Ksrv /dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0W729659E /root/data.key luks,nofail
  '';

  fileSystems."/srv/docker" = {
    device = "/dev/mapper/Ksrv";
    fsType = "btrfs";
    options = [
      "subvol=@docker"
      "compress=zstd:3"
      "noatime"
      "nodiratime"
      "nofail"
      "x-systemd.requires=systemd-cryptsetup@Ksrv.service"
    ];
  };

  fileSystems."/srv/containers" = {
    device = "/dev/mapper/Ksrv";
    fsType = "btrfs";
    options = [
      "subvol=@containers"
      "compress=zstd:3"
      "noatime"
      "nodiratime"
      "nofail"
      "x-systemd.requires=systemd-cryptsetup@Ksrv.service"
    ];
  };

  # Scrub the srv disk weekly
  services.btrfs.autoScrub.fileSystems = ["/srv/docker"];
}
# vim: set ts=2 sw=2 et ai list nu

