{ ... }:
{
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services = {

    syncthing = {
      enable = true;
    };

  }; # EOM services

} # EOF
# vim: set ts=2 sw=2 et ai list nu
