{
  pkgs,
  config,
  lib,
  ...
}: {
  environment.systemPackages =
    (with pkgs; [
      docker
      docker-buildx
      k0sctl
      k3s
      kata-runtime
      kind
      kubectx
      kubernetes-helm
      talosctl
      virtiofsd
      yamlfmt
      yamllint
    ])
    ++ (with pkgs.unstable; [
      k9s
      nerdctl
      virt-manager
    ]);

  # Add any users in the 'wheel' group to the 'libvirt' group.
  users.groups.libvirt.members = builtins.filter (
    x: builtins.elem "wheel" config.users.users."${x}".extraGroups
  ) (builtins.attrNames config.users.users);

  # No autoPrune: it runs `docker system prune`, which deletes stopped
  # containers and unused networks. Its persistent timer can fire while a
  # rebuild is restarting docker, when every container counts as stopped,
  # and wipe the lot. Images and build cache are all the space worth
  # reclaiming, and pruning only those cannot touch containers or networks.
  systemd.services.docker-image-prune = {
    description = "Prune unused Docker images and build cache";
    after = ["docker.service"];
    requires = ["docker.service"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${config.virtualisation.docker.package}/bin/docker image prune -af --filter until=168h"
        "${config.virtualisation.docker.package}/bin/docker builder prune -f"
      ];
    };
  };
  systemd.timers.docker-image-prune = {
    wantedBy = ["timers.target"];
    timerConfig = {
      # Not "weekly" (Mon 00:00): staggered after nix-gc at Mon 02:30.
      OnCalendar = "Mon *-*-* 04:00:00";
      # A missed run is skipped, never replayed on activation.
      Persistent = false;
    };
  };

  virtualisation = {
    containerd.enable = true;
    docker = {
      enable = true;
      # mkDefault so hosts on ZFS (e.g. sox1x) can override without mkForce.
      storageDriver = lib.mkDefault "overlay2";
      daemon.settings = {
        log-driver = "local";
        log-opts = {
          max-size = "50m";
          max-file = "3";
        };
        # Kata Containers OCI runtime, an alternative to runc for stronger isolation.
        # Use per-container via `runtime: kata` in compose. Default stays runc.
        runtimes = {
          kata = {
            path = "${pkgs.kata-runtime}/bin/kata-runtime";
          };
        };
      };
    };

    libvirtd = {
      enable = true;

      qemu = {
        runAsRoot = false;
        swtpm.enable = true; # Enable SWTPM for virtual TPM support
      };

      onBoot = "ignore";
      onShutdown = "shutdown";
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

