{ ... }:
{
  imports = [
    ../../../common/home-manager/eldios/services/audio.nix
  ];

  services = {
    syncthing.tray.enable = true;
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
