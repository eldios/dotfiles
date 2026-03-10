# AMD GPU configuration for mininixos (headless server)
# RX 9700 XT AI PRO 32GB (RDNA 4, Navi 48) + Raphael iGPU

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
