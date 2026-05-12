{ config, pkgs, ... }:
{
  programs = {

    kitty = {
      enable = true;
      # Pull palette from the current omarchy theme. Updated atomically by
      # `omarchy-theme-set` on every switch; kitty live-reloads via SIGUSR1
      # (sent by omarchy-restart-terminal).
      extraConfig = ''
        include ${config.home.homeDirectory}/.config/omarchy/current/theme/kitty.conf
      '';
      settings = {
        font_size = "12.0";
        dynamic_background_opacity = "yes";
        shell = "${pkgs.zsh}/bin/zsh -l";
      };
    }; # EOM kitty
  }; # EOM programs
} # EOF
# vim: set ts=2 sw=2 et ai list nu
