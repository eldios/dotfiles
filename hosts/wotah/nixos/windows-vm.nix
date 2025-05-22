# hosts/wotah/nixos/windows-vm.nix
{ config, pkgs, lib, ... }:

{
  # FIXME: Ensure this module is imported in hosts/wotah/nixos/configuration.nix
  # For example:
  # imports = [
  #   ./windows-vm.nix
  #   # ... other imports
  # ];

  config.virtualisation.libvirtd.enable = true; # Ensure libvirtd is enabled

  config.virtualisation.libvirtd.domains = [{
    name = "windows11";
    autostart = false; # User can change to true if desired
    hypervisor = "kvm"; # Use KVM
    memory = 16384; # 16GB RAM - FIXME: Adjust as needed
    vcpus = 8;      # 8 vCPUs - FIXME: Adjust as needed

    features = {
      acpi = true;
      apic = true;
      hyperv = { # Hyper-V enlightenments
        relaxed = true;
        vapic = true;
        spinlocks = true;
        vpindex = true;
        runtime = true;
        synic = true;
        stimer = true;
        reset = true;
        vendor_id = true;
        frequencies = true;
      };
      kvm = { # KVM specific features
        hidden_state = true;
      };
    };

    cpu.mode = "host-passthrough"; # Pass through host CPU features
    # Or, for more compatibility but less performance:
    # cpu.mode = "host-model";
    # cpu.model = "EPYC"; # Example: Use AMD EPYC model for Ryzen

    loader = {
      path = "${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"; # UEFI firmware
      readonly = true;
      if = "pflash";
    };
    nvram = {
      path = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd"; # UEFI variables template
      # For per-VM NVRAM, you would typically copy this template to a writable location
      # e.g., /var/lib/libvirt/qemu/nvram/\${name}_VARS.fd
      # For now, using the template directly means changes might not persist across reboots
      # or VM recreation unless libvirt manages a copy.
      # Libvirt usually handles this by creating a copy in /var/lib/libvirt/qemu/nvram/
      template = "${pkgs.OVMF.fd}/FV/OVMF_VARS.fd";
    };

    devices = {
      # Placeholder for Windows 11 disk
      # FIXME: Replace '/dev/disk/by-id/CHANGE_WITH_CORRECT_ID' with the actual disk ID
      disks = [{
        source.dev = "/dev/disk/by-id/CHANGE_WITH_CORRECT_ID";
        # Example for NVMe: source.dev = "/dev/disk/by-id/nvme-Your_NVMe_Disk_ID";
        # Example for SATA: source.dev = "/dev/disk/by-id/ata-Your_SATA_Disk_ID";
        target.bus = "virtio"; # Use virtio for better performance
        target.dev = "vda";
      }];

      # Placeholder for Nvidia 3090 GPU
      # FIXME: Replace XXXX and YYYY with actual PCI vendor/device IDs from 'lspci -nnk'
      # The PCI slot (e.g., 0000:0c:00.0) will also be needed from lspci (non-numeric part).
      # The worker should use placeholder bus numbers for now.
      # Example: 0000:0c:00.0 -> bus = "0x0c"; slot = "0x00"; function = "0x0";
      hostpci = [
        { # GPU
          source.address.domain = "0x0000"; # Placeholder
          source.address.bus = "0x0a";     # Placeholder - FIXME
          source.address.slot = "0x00";    # Placeholder - FIXME
          source.address.function = "0x0"; # Placeholder - FIXME
          comment = "FIXME: Nvidia 3090 GPU - Replace with actual PCI address (lspci)";
        }
        { # GPU Audio
          source.address.domain = "0x0000"; # Placeholder
          source.address.bus = "0x0a";     # Placeholder - FIXME
          source.address.slot = "0x00";    # Placeholder - FIXME
          source.address.function = "0x1"; # Placeholder - FIXME (often .1 for audio)
          comment = "FIXME: Nvidia 3090 Audio - Replace with actual PCI address (lspci)";
        }
      ];

      # Input devices
      inputs = [
        { type = "tablet"; bus = "usb"; } # For accurate mouse pointer
      ];

      # Network interface (default NAT)
      interfaces = [{
        type = "network";
        source.network = "default"; # Uses libvirt's default NAT network
        target.model = "virtio";
      }];

      # Sound device (virtual) - can be removed if GPU audio passthrough works perfectly
      sound.model = "ich9";

      # TPM device
      tpm = {
        backend.type = "emulator"; # Uses swtpm
        backend.version = "2.0";
        model = "tpm-crb"; # TPM2 CRB interface
      };

      # USB controller (optional, for easier USB passthrough)
      controllers = [
        { type = "usb"; model = "qemu-xhci"; ports = 8; }
      ];

      # Necessary for some GPUs, especially Nvidia, to hide KVM virtualization from guest drivers
      features = lib.mkOptionDefault {
        hyperv.vendor_id.value = "NvidiaFuckU"; # Can be any 12 char string
        kvm.hidden.value = true;
      };

    }; # End devices

    # Recommended: Define a unique MAC address if needed, otherwise one will be generated
    # devices.interfaces.mac.address = "52:54:00:xx:yy:zz";

    # FIXME: User needs to download Windows 11 ISO and VirtIO drivers ISO.
    # These can be attached via virt-manager or by defining a cdrom device here.
    # Example for attaching an ISO at boot:
    # devices.cdroms = [{
    #   source.file = "/path/to/windows11.iso"; # FIXME
    #   target.dev = "hda";
    #   target.bus = "sata";
    # }];
    # It's often easier to manage ISOs via virt-manager GUI for installation.
  }];
}
