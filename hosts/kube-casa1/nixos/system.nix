{ peerix, pkgs, ... }:
{
  system = {
    stateVersion = "24.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  services = {
    zfs = {
      autoScrub = {
        enable = true;
        interval = "weekly";
      };
      trim.enable = true;
    };

    peerix = {
      enable = true;
      package = peerix.packages.${pkgs.system}.peerix;
      openFirewall = false;
      #privateKeyFile = config.sops.secrets."keys/peerix/private".path;
      #publicKeyFile = config.sops.secrets."keys/peerix/public".path;
      #publicKey = "key1 key2 key3";
    };

    environment.etc.crypttab = {
      enable = true;
      text = ''
        KMb /dev/disk/by-id/ata-WDC_WD102KFBX-68M95N0_VCG9HBKM-part1 /root/data.key luks
        KMc /dev/disk/by-id/ata-WDC_WD102KFBX-68M95N0_VCG6MLWN-part1 /root/data.key luks
      '';
    };
    fileSystems."10TB" = {
      label = "10TB";
      mountPoint = "/data/10TB";
      fsType = "btrfs";
    };
    plex = {
      enable = true;
      openFirewall = true;
      user = "eldios";
      group = "users";
      accelerationDevices = [
        "/dev/dri/renderD128"
      ];
      dataDir = [
        "/data/10TB/data/plex"
      ];
    };
  };

}

# vim: set ts=2 sw=2 et ai list nu
