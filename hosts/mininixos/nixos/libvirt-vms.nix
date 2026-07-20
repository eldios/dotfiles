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

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.bash}/bin/bash -c \"state=$(${pkgs.libvirt}/bin/virsh domstate HomeAssistant 2>/dev/null || echo 'shut off'); [[ $state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start HomeAssistant || exit 0\"";
        ExecStop = "${pkgs.libvirt}/bin/virsh shutdown HomeAssistant";
      };
    };

  };
}

# vim: set ts=2 sw=2 et ai list nu
