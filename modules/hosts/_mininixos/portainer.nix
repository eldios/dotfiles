# Portainer as a NixOS-managed container: the one container that must come up
# with the host, so the stacks under /srv/containers can be managed from it.
{
  inputs,
  config,
  ...
}: {
  # With AGENT_SECRET set, the server signs the secret instead of a default
  # message, and an agent holding the same secret trusts only this server.
  sops.secrets."portainer/agent-secret" = {
    sopsFile = "${toString inputs.secrets}/mininixos.yaml";
  };

  sops.templates."portainer.env" = {
    content = "AGENT_SECRET=${config.sops.placeholder."portainer/agent-secret"}\n";
    restartUnits = ["docker-portainer.service"];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers.portainer = {
      # Agents must run the same version, so it moves only by hand together
      # with them. The default pull policy ("missing") never refreshes a
      # moving tag.
      image = "portainer/portainer-ce:2.45.3";
      environmentFiles = [config.sops.templates."portainer.env".path];
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

