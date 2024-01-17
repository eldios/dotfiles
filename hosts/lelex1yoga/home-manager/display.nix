{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    #wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    config.common.default = "*" ;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;

    extraConfig = ''
      # set background
      #output "*" bg IMAGE_FILE fill
    '';
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "alacritty"; 
      output = {
        "Virtual-1" = {
          mode = "1920x1080@60Hz";
        };
      };
      startup = [
        # Launch Firefox on start
        {
          command = "alacritty";
        }
      ];
    };
  };

  # EOM Sway confguration

  # # i3 config
  # xsession.windowManager.i3 = {
  #   enable = true;
  #   config = {
  #     modifier = "Mod4" ;
  #   };
  # };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
