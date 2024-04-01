{
  environment.etc = {
    "rancher/k3s/config.yaml.d/fsn-c3.yaml" = {
      text = ''
        advertise-address: 10.1.0.4
        node-ip: 10.1.0.4
        node-external-ip: 138.201.190.214
      '';
      mode = "0440";
    };
  };

  services.k3s = {
    enable = true;

    role = "server"; # or agent
    #disableAgent = true; # Only run the server

    serverAddr = "https://10.1.0.2:6443";
    tokenFile = "/tmp/k3s_token";
  };
}
