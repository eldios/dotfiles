{ pkgs, config, ... }:
{
  environment.systemPackages =
    (with pkgs; [
      docker
      docker-buildx
      k0sctl
      k3s
      kind
      kind
      kubectx
      kubelogin
      kubelogin-oidc
      kubernetes-helm
      talosctl
      virtiofsd
      yamlfmt
      yamllint
    ])
    ++ (with pkgs.unstable; [
      k9s
      nerdctl
      virt-manager
    ]);

  # Add any users in the 'wheel' group to the 'libvirt' group.
  users.groups.libvirt.members = builtins.filter (
    x: builtins.elem "wheel" config.users.users."${x}".extraGroups
  ) (builtins.attrNames config.users.users);

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
        runAsRoot = false;
        swtpm.enable = true; # Enable SWTPM for virtual TPM support
      };

      onBoot = "ignore";
      onShutdown = "shutdown";
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
