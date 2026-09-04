# AMD graphics: the nixos-hardware baseline, ROCm OpenCL, LACT for fan
# curves and power caps, and the monitoring tools ROCm workloads lean on.
{inputs, ...}: {
  den.aspects.gpu-amd.nixos = {pkgs, ...}: {
    imports = [inputs.nixos-hardware.nixosModules.common-gpu-amd];

    hardware = {
      graphics = {
        enable = true;
        extraPackages = [pkgs.rocmPackages.clr.icd];
      };

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
}
