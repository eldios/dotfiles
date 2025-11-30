# Libvirt VM systemd services
# Manage VM startup with proper dependencies

{ pkgs, ... }:

{
  # configuration.nix - il modo più semplice
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.containers = {
    portainer = {
      image = "portainer/portainer-ce:latest";
      ports = [ "9443:9443" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/data/containers:/data"
      ];
    };
  };

  systemd.services = {
    # Umbrel VM
    "libvirt-vm-umbrel" = {
      description = "Libvirt VM: Umbrel";
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.bash}/bin/bash -c \"state=$(${pkgs.libvirt}/bin/virsh domstate Umbrel 2>/dev/null || echo 'shut off'); [[ $state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start Umbrel || exit 0\"";
        ExecStop = "${pkgs.libvirt}/bin/virsh shutdown Umbrel";
      };
    };

    # HomeAssistant VM
    "libvirt-vm-homeassistant" = {
      description = "Libvirt VM: HomeAssistant";
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.bash}/bin/bash -c \"state=$(${pkgs.libvirt}/bin/virsh domstate HomeAssistant 2>/dev/null || echo 'shut off'); [[ $state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start HomeAssistant || exit 0\"";
        ExecStop = "${pkgs.libvirt}/bin/virsh shutdown HomeAssistant";
      };
    };

    # bsdino VM
    "libvirt-vm-bsdino" = {
      description = "Libvirt VM: bsdino";
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${pkgs.bash}/bin/bash -c \"state=$(${pkgs.libvirt}/bin/virsh domstate bsdino 2>/dev/null || echo 'shut off'); [[ $state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start bsdino || exit 0\"";
        ExecStop = "${pkgs.libvirt}/bin/virsh shutdown bsdino";
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
