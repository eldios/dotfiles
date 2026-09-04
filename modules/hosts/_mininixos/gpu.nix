# Radeon AI PRO R9700 32GB (RDNA 4, Navi 48, 1002:7551) + Raphael iGPU (1002:164e)
{
  # Cap the R9700 at 210W (board max 300W) to keep temperatures in check on a
  # 24/7 headless box. Matched by PCI id so the Raphael iGPU is untouched.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hwmon", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x7551", ATTR{power1_cap}="210000000"
  '';
}
# vim: set ts=2 sw=2 et ai list nu

