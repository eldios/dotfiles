{pkgs, ...}: {
  system = {
    stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    autoUpgrade.enable = true;
  };

  # Laptop: sleep allowed, lid behavior from the base suspend module
  machine.suspend.enable = true;

  # Finger unlock on the lockscreen: keeps pam_fprintd in hyprlock's stack;
  # hyprlock.nix follows this and runs password and fingerprint in parallel.
  security.pam.services.hyprlock.fprintAuth = true;

  services = {
    btrfs = {
      autoScrub = {
        enable = true;
        # Not "weekly" (Mon 00:00): that collides with nix-gc, fstrim and
        # docker prune. Scrub is the heaviest job (hours), so it gets its
        # own day.
        interval = "Sat *-*-* 05:30:00";
      };
    };

    libinput = {
      enable = true;
      touchpad = {
        clickMethod = "clickfinger";
        #clickMethod = "buttonareas";
        disableWhileTyping = true;
        middleEmulation = false;
        tappingDragLock = false;
        tappingButtonMap = "lrm";
        scrollMethod = "twofinger";
      };
    };

    xserver.videoDrivers = ["modesetting"];
  };

  environment.systemPackages = with pkgs; [
    proton-vpn
  ];
}
# vim: set ts=2 sw=2 et ai list nu

