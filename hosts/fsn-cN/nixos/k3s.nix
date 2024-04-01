{
  environment.etc = {
    "rancher/k3s/config.yaml" = {
      text = ''
        secrets-encryption: true
        disable:
          - traefik
          - servicelb

        tls-san:
          - fsn-kube.lele.rip
          # fsn-c1
          - 10.1.0.2
          - 116.202.108.212
          # fsn-c2
          - 10.1.0.3
          - 159.69.248.126
          # fsn-c3
          - 10.1.0.4
          - 138.201.190.214
          # load balancer
          - 142.132.247.5
          - 2a01:4f8:c01e:900::1
      '';
      mode = "0440";
    };
  };
}
