# AMD graphics: the nixos-hardware baseline, ROCm OpenCL, LACT for fan
# curves and power caps, the monitoring tools ROCm workloads lean on, and
# the VA-API and VDPAU driver selection for the user's session.
{inputs, ...}: {
  den.aspects.gpu-amd = {
    nixos = {pkgs, ...}: {
      imports = [inputs.nixos-hardware.nixosModules.common-gpu-amd];

      hardware = {
        graphics.enable = true;

        # opencl brings the ROCm CLR and its ICD into hardware.graphics.
        amdgpu = {
          opencl.enable = true;
          initrd.enable = true;
        };
      };

      # GPU fan curves, power limits, clocking (daemon + CLI)
      services.lact.enable = true;

      # AMD GPU monitoring and diagnostic tools (useful with Ollama ROCm)
      environment.systemPackages = with pkgs; [
        amdgpu_top # TUI: VRAM, clocks, temps, GPU usage
        nvtopPackages.amd # htop-like GPU process monitor
        rocmPackages.rocm-smi # AMD official GPU management CLI
        rocmPackages.rocminfo # ROCm agent and capability info
        clinfo # OpenCL stack verification
      ];
    };

    homeManager.home.sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
    };
  };
}
