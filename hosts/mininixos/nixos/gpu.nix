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
}

# vim: set ts=2 sw=2 et ai list nu
