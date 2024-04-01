{
  services.k3s = {
    enable = true;

    clusterInit = true;

    role = "server"; # or agent

    #disableAgent = true; # Only run the server

    configPath = "/etc/rancher/k3s/config.yaml";
    #environmentFile = "/etc/rancher/k3s/env";

    extraFlags = "--disable traefik,servicelb";
  };
}
