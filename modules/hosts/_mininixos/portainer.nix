# Portainer as a NixOS-managed container: the one container that must come up
# with the host, so the stacks under /srv/containers can be managed from it.
{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.portainer = {
      image = "portainer/portainer-ce:latest";
      ports = ["9443:9443"];
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
}
# vim: set ts=2 sw=2 et ai list nu

