# AMD GPU tools for lele8845ace
# Monitoring and diagnostics for ROCm / Ollama workloads

{ pkgs, ... }:
{
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
