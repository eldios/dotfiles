{ pkgs, ... }:

{
  # Enable CUPS printing service
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

  # Enable printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Hardware support for scanners (MFC includes scanner)
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

  # Add user to scanner and lp groups
  users.users.eldios.extraGroups = [
    "scanner"
    "lp"
  ];
}

# vim: set ts=2 sw=2 et ai list nu
