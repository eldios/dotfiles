# GDM as the login manager, with the X server it expects underneath. Hosts
# that want a different display manager simply do not include this.
{
  den.aspects.gdm.nixos = {
    services = {
      displayManager.gdm.enable = true;
      xserver = {
        enable = true;
        autorun = true;
      };
    };
  };
}
