{pkgs, ...}: {
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  # 24 threads and 64GB here: allow more build parallelism than the
  # common default.
  nix.settings.cores = 12;

  services = {
    hardware = {
      openrgb = {
        enable = false; # disabled since mbed-tls is insecure for now
        motherboard = "amd";
        package = pkgs.openrgb-with-all-plugins;
      };
    };

    # don't shutdown when power button is short-pressed
    logind.settings.Login.HandlePowerKey = "ignore";

    btrfs = {
      autoScrub = {
        enable = true;
        # Not "weekly" (Mon 00:00): that collides with nix-gc, fstrim and
        # docker prune. Scrub is the heaviest job (hours), so it gets its
        # own day, after the 04:40 nixos-upgrade window.
        interval = "Sat *-*-* 05:30:00";
      };
    };

    cloudflared.enable = true;

    xserver.videoDrivers = ["amdgpu"];
  };

  # https://wiki.archlinux.org/title/GPGPU#ICD_loader_(libOpenCL.so)
  environment.etc."ld.so.conf.d/00-usrlib.conf".text = "/usr/lib";

  # VDPAU on top of the VA-API stack the gpu-amd aspect installs.
  hardware.graphics.extraPackages = with pkgs; [
    libvdpau-va-gl
    libva-vdpau-driver
  ];
}
# vim: set ts=2 sw=2 et ai list nu

