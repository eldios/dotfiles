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

  # Cap the R9700 at 210W (board max 300W) to keep temperatures in check on a
  # 24/7 headless box. Matched by PCI id so the Raphael iGPU is untouched.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hwmon", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x7551", ATTR{power1_cap}="210000000"
  '';

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
