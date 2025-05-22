{ pkgs, ... }:
{
  programs = {

    kitty = {
      enable = true;
      settings = {
        # INFO: Kitty colors and theme are managed by Stylix.
        font_size = "12.0";
        dynamic_background_opacity = "yes";
        # ZSH
        shell = "${pkgs.zsh}/bin/zsh -l";
        # nushell
        #shell = "${pkgs.nushell}/bin/nu -l";
      };
    }; # EOM kitty
  }; # EOM programs
} # EOF
# vim: set ts=2 sw=2 et ai list nu
