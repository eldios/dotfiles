# Libvirt VM systemd services
# Manage VM startup with proper dependencies
{pkgs, ...}: {
  systemd.services = {
    # HomeAssistant VM
    "libvirt-vm-homeassistant" = {
      description = "Libvirt VM: HomeAssistant";
      after = ["libvirtd.service"];
      wantedBy = ["multi-user.target"];
      # libvirt-guests stops every guest when libvirtd restarts, and a oneshot
      # with RemainAfterExit stays active across that, so ExecStart would never
      # run again. partOf ties the unit to libvirtd so it restarts with it.
      partOf = ["libvirtd.service"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        # virsh shutdown only asks the guest to power off, so the stop has to
        # wait for it: otherwise ExecStart finds the domain still running,
        # skips the start, and the guest settles into shut off with nobody
        # left to bring it up.
        TimeoutStopSec = "150";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh domstate HomeAssistant | grep -q running || ${pkgs.libvirt}/bin/virsh start HomeAssistant'";
        ExecStop = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh shutdown HomeAssistant || true; for i in $(seq 1 60); do ${pkgs.libvirt}/bin/virsh domstate HomeAssistant | grep -q shut && exit 0; sleep 2; done'";
      };
    };

    # bsdino has an interface on br13, and libvirt refuses to start a guest
    # whose bridge does not exist. When the VLAN 13 dongle is enumerated after
    # the device timeout, br13 comes up after libvirt autostart has already
    # failed, so the guest is started from br13-netdev instead of a target.
    "libvirt-vm-bsdino" = {
      description = "Libvirt VM: bsdino";
      wantedBy = ["br13-netdev.service"];
      wants = ["libvirtd.service"];
      after = ["libvirtd.service" "br13-netdev.service"];
      # Re-run every time br13 is recreated. There is no ExecStop on purpose:
      # losing the bridge must not power off the guest, br13-netdev re-enslaves
      # its tap when the bridge comes back.
      partOf = ["libvirtd.service" "br13-netdev.service"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        # libvirt autostart may be starting the domain at the same moment, so
        # a failed start still counts as success once the domain is running.
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.libvirt}/bin/virsh domstate bsdino | grep -q running || ${pkgs.libvirt}/bin/virsh start bsdino || ${pkgs.libvirt}/bin/virsh domstate bsdino | grep -q running'";
      };
    };
  };
}
# vim: set ts=2 sw=2 et ai list nu

