{ pkgs, ... }:
{

  alacritty = {
    enable = true;
    settings = {
      font = {
        size = 11.0;
        normal = {
          family = "MesloLGS NF";
          style = "Regular";
        };
      };
    };
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
