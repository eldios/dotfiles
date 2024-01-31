{ config, pkgs, ...}:

{
  imports = [
    ./programs/sway.nix
    ./programs/hyprland.nix
    ./programs/waybar.nix
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };


  home = {
    pointerCursor = {
      gtk.enable = true;
      # cursor theme
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
    };

    packages = with pkgs; [
      adwaita-qt
      adwaita-qt6
      bemenu # wayland clone of dmenu
      clipman
      dconf
      dracula-theme # gtk theme
      eww-wayland # wayland widgets - https://github.com/elkowar/eww
      fuseiso
      fuzzel # wayland clone of dmenu
      gammastep
      geoclue2
      glpaper
      gnome.adwaita-icon-theme
      gnome.gnome-themes-extra
      gnome3.adwaita-icon-theme  # default gnome cursors
      grim # screenshot functionality
      grimblast # screenshot functionality
      gsettings-desktop-schemas
      hyprland-protocols
      hyprpaper
      hyprpicker
      lavalauncher # simple launcher panel for Wayland desktops
      libva-utils
      mako # notification system developed by swaywm maintainer
      pinentry-bemenu
      polkit_gnome
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      rofi-wayland-unwrapped
      shotman
      slurp # screenshot functionality
      swaybg
      swayidle
      swaylock-effects
      swaynotificationcenter
      swayr
      swayrbar
      swww
      tofi
      udiskie
      wayland
      wbg
      wdisplays # tool to configure displays
      wev
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      wl-gammactl
      wl-screenrec
      wlogout
      wlr-randr
      wlroots
      wlsunset
      wofi
      wshowkeys
      wtype
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-hyprland
      xdg-utils # for opening default programs when clicking links
      ydotool
    ]; # EOM swap / wayland / hyprland deps
  };

} # EOF
# vim: set ts=2 sw=2 et ai list nu
