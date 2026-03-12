# 1.8TB secondary disk: LUKS + BTRFS → /srv
#
# Initial setup (run ONCE on mininixos):
#
#   # 1. Identify disk
#   ls -l /dev/disk/by-id/ | grep sd
#
#   # 2. LUKS format (interactive passphrase)
#   sudo cryptsetup luksFormat /dev/disk/by-id/<DISK_ID>
#
#   # 3. Generate key file and add as second LUKS slot
#   sudo dd if=/dev/urandom of=/root/srv.key bs=4096 count=1
#   sudo chmod 400 /root/srv.key
#   sudo cryptsetup luksAddKey /dev/disk/by-id/<DISK_ID> /root/srv.key
#
#   # 4. Open, format, create subvolumes
#   sudo cryptsetup open /dev/disk/by-id/<DISK_ID> Ksrv --key-file /root/srv.key
#   sudo mkfs.btrfs -L srv -f /dev/mapper/Ksrv
#   sudo mount /dev/mapper/Ksrv /mnt
#   sudo btrfs subvolume create /mnt/@docker
#   sudo btrfs subvolume create /mnt/@containers
#   sudo umount /mnt
#   sudo cryptsetup close Ksrv
#
#   # 5. nixos-rebuild switch, then reboot
#
# After RAID /data is back:
#   Move Portainer volume back to /data/containers/portainer if desired,
#   or keep on /srv/containers/portainer permanently.

{ ... }:

{
  # Post-boot LUKS decryption via crypttab
  # Key file on encrypted root → auto-unlock after Yubikey unlocks root
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
  services.btrfs.autoScrub.fileSystems = [ "/srv/docker" ];
}

# vim: set ts=2 sw=2 et ai list nu
