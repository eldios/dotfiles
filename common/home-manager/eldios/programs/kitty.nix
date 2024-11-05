{ pkgs, ... }:
{
  programs = {

    kitty = {
      enable = true;
      settings = {
        font_size = "12.0";
        background_opacity = "0.9";
        dynamic_background_opacity = "yes";
        #shell = "${pkgs.zsh}/bin/zsh -l";
        shell = "${pkgs.nushell}/bin/nu -l";
      };
    }; # EOM kitty
  }; # EOM programs
} # EOF
# vim: set ts=2 sw=2 et ai list nu
