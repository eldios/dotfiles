# common/home-manager/eldios/programs/ghostty.nix
{ config, lib, pkgs, ... }:
{
  programs = {
    ghostty = {
      enable = true;

      # Ghostty settings
      settings = {
        # Window settings
        window-decoration = false;
        window-padding-x = 10;
        window-padding-y = 10;
        background-opacity = 0.95;

        # Fonts (colors come from the omarchy theme via config-file below)
        font-family = "DejaVu Sans Mono";
        font-size = "12";
        font-feature = "calt liga";

        # Cursor settings
        cursor-style = "block";

        # Misc settings
        macos-option-as-alt = true;
        confirm-close-surface = false;

        # Pull palette from the current omarchy theme. Updated atomically by
        # `omarchy-theme-set` on every switch; ghostty reloads via SIGUSR2
        # (sent by omarchy-restart-terminal).
        config-file = "${config.home.homeDirectory}/.config/omarchy/current/theme/ghostty.conf";
      };
    };
  };
}
