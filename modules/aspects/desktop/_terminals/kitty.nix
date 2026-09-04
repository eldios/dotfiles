{
  config,
  pkgs,
  ...
}: {
  programs = {
    kitty = {
      enable = true;
      # Pull palette from the theme riso renders; kitty live-reloads via
      # SIGUSR1.
      extraConfig = ''
        include ${config.home.homeDirectory}/.local/state/riso/current/theme/kitty.conf
      '';
      settings = {
        font_size = "12.0";
        dynamic_background_opacity = "yes";
        shell = "${pkgs.zsh}/bin/zsh -l";
      };
    }; # EOM kitty
  }; # EOM programs
}
# EOF
# vim: set ts=2 sw=2 et ai list nu

