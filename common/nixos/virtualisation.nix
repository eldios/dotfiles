{ inputs , pkgs , config , lib , ... }:
{
  environment.systemPackages = with pkgs; [
    # Docker
    devspace
    docker
    docker-buildx
    kubernetes-helm
    k9s
    kind
    kubectl
    nerdctl

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
      storageDriver = "zfs";
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
