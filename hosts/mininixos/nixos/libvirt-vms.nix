# Libvirt VM systemd services
# Manage VM startup with proper dependencies

{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers.portainer = {
      image = "portainer/portainer-ce:latest";
      ports = [ "9443:9443" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/srv/containers/portainer:/data"
        "/srv/containers/:/srv/containers/:ro"
      ];
      extraOptions = [
        "--network=proxy"
        "--label=traefik.enable=true"
        "--label=traefik.docker.network=proxy"
        "--label=traefik.http.services.portainer.loadbalancer.server.port=9000"
        "--label=traefik.http.routers.portainer.rule=Host(`portainer.casa.lele.rip`) || Host(`portainer.vpn.lele.rip`)"
        "--label=traefik.http.routers.portainer.tls=true"
        "--label=traefik.http.routers.portainer.tls.certresolver=cloudflare"
      ];
    };
  };

  systemd.services = {
    # HomeAssistant VM
    "libvirt-vm-homeassistant" = {
      description = "Libvirt VM: HomeAssistant";
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      # libvirt-guests stops every guest when libvirtd restarts, and a oneshot
      # with RemainAfterExit stays active across that, so ExecStart would never
      # run again. partOf ties the unit to libvirtd so it restarts with it.
      partOf = [ "libvirtd.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        # virsh shutdown only asks the guest to power off, so the stop has to
        # wait for it: otherwise ExecStart finds the domain still running,
        # skips the start, and the guest settles into shut off with nobody
        # left to bring it up.
        TimeoutStopSec = "150";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh domstate HomeAssistant | grep -q running || ${pkgs.libvirt}/bin/virsh start HomeAssistant'";
        ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh shutdown HomeAssistant || true; for i in $(seq 1 60); do ${pkgs.libvirt}/bin/virsh domstate HomeAssistant | grep -q shut && exit 0; sleep 2; done'";
      };
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
