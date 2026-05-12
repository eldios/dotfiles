{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.mako];

  services.mako.enable = false;

  # Upstream omarchy pattern: only include the current theme's mako.ini, which
  # itself includes core.ini via template-generated content. Themes can opt out
  # of inheriting core (matches upstream behavior bit-for-bit).
  xdg.configFile."mako/config".text = ''
    include=${config.home.homeDirectory}/.config/omarchy/current/theme/mako.ini
  '';
}
