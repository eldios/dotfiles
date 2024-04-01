{
  services.k3s = {
    enable = true;

    role = "server"; # or agent

    serverAddr = "https://10.1.0.2:6443";
    tokenFile = "/tmp/k3s_token";

    #disableAgent = true; # Only run the server

    configPath = "/etc/rancher/k3s/config.yaml";
    #environmentFile = "/etc/rancher/k3s/env";

    extraFlags = "";
  };
}
