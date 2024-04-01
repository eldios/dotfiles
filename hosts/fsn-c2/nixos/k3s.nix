{
  services.k3s = {
    enable = true;

    role = "server"; # or agent

    serverAddr = "10.1.0.2";
    tokenFile = "/tmp/k3s_token";

    #disableAgent = true; # Only run the server

    configPath = "/etc/rancher/k3s/config.yaml";
    #environmentFile = "/etc/rancher/k3s/env";

    extraFlags = "";
  };
}
