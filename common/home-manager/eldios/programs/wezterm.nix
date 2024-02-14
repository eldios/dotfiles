{ pkgs, ... }:
{

  programs = {

    wezterm = {
      enable = true;

      enableZshIntegration = true;

      extraConfig = ''
        local config = {}

        config = {
          use_fancy_tab_bar = true,
          enable_tab_bar = true,
          hide_tab_bar_if_only_one_tab = true,
          tab_bar_at_bottom = false,
        }

        return config
      ''; # EOM extraConfig
    }; # EOM alacritty
  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
