# Intel integrated graphics: VA-API through the iHD media driver, oneVPL and
# the OpenCL compute runtime.
{
  den.aspects.gpu-intel.nixos = {pkgs, ...}: {
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

    # https://wiki.archlinux.org/title/GPGPU
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
        libva-utils
        intel-graphics-compiler
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vpl-gpu-rt
        intel-compute-runtime
      ];
    };
  };
}
