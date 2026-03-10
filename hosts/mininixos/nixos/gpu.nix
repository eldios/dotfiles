# AMD GPU configuration for mininixos (headless server)
# Radeon AI PRO R9700 32GB (RDNA 4, Navi 48, 1002:7551) + Raphael iGPU (1002:164e)

{ pkgs, ... }:
{
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        rocmPackages.clr.icd
      ];
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
    amdgpu_top              # TUI: VRAM, clocks, temps, GPU usage
    nvtopPackages.amd       # htop-like GPU process monitor
    rocmPackages.rocm-smi   # AMD official GPU management CLI
    rocmPackages.rocminfo   # ROCm agent and capability info
    clinfo                  # OpenCL stack verification
  ];
}

# vim: set ts=2 sw=2 et ai list nu
