# CUPS with the drivers for the printers in the house, mDNS discovery for
# them, and scanner support for the multifunction units.
{
  den.aspects.printing = {
    nixos = {pkgs, ...}: {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          gutenprint
          gutenprintBin
          hplip
          splix
          brlaser
          brgenml1lpr
          brgenml1cupswrapper
        ];
      };

      # Printer discovery.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };

      # Scanners (the MFCs include one).
      hardware.sane = {
        enable = true;
        extraBackends = with pkgs; [
          sane-airscan
          brscan4
          brscan5
        ];
        brscan4 = {
          enable = true;
        };
      };

      users.users.eldios.extraGroups = [
        "scanner"
        "lp"
      ];
    };
  };
}
