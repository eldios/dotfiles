{ pkgs, ... }:
{
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services = {

    syncthing = {
      enable = true;
    };

    cockpit = {
      enable = false;
      openFirewall = true;
    };

    gpg-agent = {
      enable = true;
      pinentryFlavor = "curses";

      enableSshSupport = true;
      enableZshIntegration = true;

      extraConfig = ''
        #debug-pinentry
        #debug ipc
        #debug-level 1024

        # I don't use smart cards
        disable-scdaemon
      '';
    };
  }; # EOM services

} # EOF
# vim: set ts=2 sw=2 et ai list nu
