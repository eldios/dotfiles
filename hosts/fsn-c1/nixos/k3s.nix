{
  environment.etc = {
    "rancher/k3s/config.yaml.d/fsn-c1.yaml" = {
      text = ''
        cluter-init: true
        advertise-address: 10.1.0.2
        node-ip:10.1.0.2
        node-external-ip:116.202.108.212
      '';
      mode = "0440";
    };
  };

  services.k3s = {
    enable = true;

    clusterInit = true;

    role = "server"; # or agent

    #disableAgent = true; # Only run the server
  };
}
