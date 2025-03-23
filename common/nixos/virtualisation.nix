{ pkgs , config , lib , ... }:
{
  environment.systemPackages = with pkgs; [
    # Docker
    docker
    docker-buildx
    k0sctl
    k3s
    k9s
    kind
    kind
    kubectx
    kubelogin
    kubelogin-oidc
    kubernetes-helm
    kubernetes-helm
    nerdctl
    yamlfmt
    yamllint

    # Virtualisation
    virt-manager
    virtiofsd
  ];

  # Add any users in the 'wheel' group to the 'libvirt' group.
  users.groups.libvirt.members = builtins.filter (x: builtins.elem "wheel" config.users.users."${x}".extraGroups) (builtins.attrNames config.users.users);

  virtualisation = {
    containerd.enable = true;
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    libvirtd = {
      enable = true;

      qemu = {
        ovmf.enable = true;
        runAsRoot = false;
      };

      onBoot = "ignore";
      onShutdown = "shutdown";
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
