{ pkgs, ... }:
{
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  services = {

    syncthing = {
      enable = true;
    };

    gpg-agent = {
      enable = true;

      enableSshSupport = true;
      enableZshIntegration = true;

      extraConfig = ''
        #debug-pinentry
        #debug ipc
        #debug-level 1024

        # I don't use smart cards
        disable-scdaemon

        pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
      '';
    };
  }; # EOM services

} # EOF
# vim: set ts=2 sw=2 et ai list nu
