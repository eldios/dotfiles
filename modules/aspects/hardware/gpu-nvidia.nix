# NVIDIA graphics with PRIME offload: the nixos-hardware baseline and the
# proprietary driver settings any Optimus laptop shares. PCI bus ids are
# per machine and stay in the host.
{inputs, ...}: {
  den.aspects.gpu-nvidia.nixos = {
    imports = [inputs.nixos-hardware.nixosModules.common-gpu-nvidia];

    services.xserver.videoDrivers = ["nvidia"];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };

      nvidia = {
        prime.offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
        powerManagement.enable = false;
        # Fine-grained power management. Turns off GPU when not in use.
        # Experimental and only works on modern Nvidia GPUs (Turing or newer).
        powerManagement.finegrained = false;

        # Use the NVidia open source kernel module (not to be confused with the
        # independent third-party "nouveau" open source driver).
        # Support is limited to the Turing and later architectures. Full list of
        # supported GPUs is at:
        # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
        # Only available from driver 515.43.04+
        # Currently alpha-quality/buggy, so false is currently the recommended setting.
        open = false;

        # Enable the Nvidia settings menu,
        # accessible via `nvidia-settings`.
        nvidiaSettings = true;
      };
    };
  };
}
