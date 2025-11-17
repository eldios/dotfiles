# Libvirt VM systemd services
# Manage VM startup with proper dependencies

{ pkgs, ... }:

{
  systemd.services = {
    # Media VM - requires /data mount
    "libvirt-vm-media" = {
      description = "Libvirt VM: media (requires /data)";
      after = [ "data.mount" "libvirtd.service" ];
      requires = [ "data.mount" ];
      bindsTo = [ "data.mount" ];  # Stop VM if /data unmounts
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        # Only start if not already running (idempotent)
        ExecStart = ''${pkgs.bash}/bin/bash -c "state=$(${pkgs.libvirt}/bin/virsh domstate media 2>/dev/null || echo 'shut off'); [[ \$state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start media || exit 0"'';
        ExecStop = "${pkgs.libvirt}/bin/virsh shutdown media";
      };
    };

    # Umbrel VM
    "libvirt-vm-umbrel" = {
      description = "Libvirt VM: Umbrel";
      after = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = ''${pkgs.bash}/bin/bash -c "state=$(${pkgs.libvirt}/bin/virsh domstate Umbrel 2>/dev/null || echo 'shut off'); [[ \$state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start Umbrel || exit 0"'';
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
        ExecStart = ''${pkgs.bash}/bin/bash -c "state=$(${pkgs.libvirt}/bin/virsh domstate HomeAssistant 2>/dev/null || echo 'shut off'); [[ \$state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start HomeAssistant || exit 0"'';
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
        ExecStart = ''${pkgs.bash}/bin/bash -c "state=$(${pkgs.libvirt}/bin/virsh domstate bsdino 2>/dev/null || echo 'shut off'); [[ \$state == 'shut off' ]] && ${pkgs.libvirt}/bin/virsh start bsdino || exit 0"'';
        ExecStop = "${pkgs.libvirt}/bin/virsh shutdown bsdino";
      };
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
