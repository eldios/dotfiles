# Shared desktop/laptop GUI configuration
# Common settings for graphical systems (bluetooth, XDG portal, security, etc.)
{
  pkgs,
  lib,
  ...
}: {
  # Bluetooth, with the blueman tray applet on every graphical host.
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = lib.mkDefault true;
    powerOnBoot = lib.mkDefault true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  # uinput for xRemap
  hardware.uinput.enable = lib.mkDefault true;

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    wlr.enable = true;
    config = {
      common.default = ["gtk"];
      hyprland = {
        default = [
          "gtk"
          "hyprland"
        ];
        # Pin screencast/screenshot to hyprland. wlr (enabled for other wlroots
        # sessions) also advertises ScreenCast, and the frontend invoking both
        # makes the share picker appear twice. Explicit routing removes it.
        "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
        "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
      };
    };
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
      # xdg-desktop-portal-hyprland provided by programs.hyprland.portalPackage
      # xdg-desktop-portal-wlr added automatically by wlr.enable = true above
    ];
  };

  # D-Bus for XDG portal
  services.dbus.enable = true;

  # GNOME keyring for secrets
  services.gnome.gnome-keyring.enable = lib.mkDefault true;

  # GVfs for file manager support
  services.gvfs.enable = lib.mkDefault true;

  # GTK theming via GSettings. dconf provides the writable backend; the
  # desktop schemas + icon theme provide org.gnome.desktop.interface
  # (color-scheme, gtk-theme) that omarchy-theme-set reads/writes.
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    gsettings-desktop-schemas
    adwaita-icon-theme
  ];

  # Nix relocates GSettings schemas under share/gsettings-schemas/<pkg>/,
  # so they are not on the default search path of a bare Wayland WM (unlike
  # GNOME/Cinnamon sessions which add it). Without this `gsettings` finds 0
  # schemas and omarchy-theme-set's `gsettings set` silently no-ops.
  environment.sessionVariables.GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

  # Qt apps follow the same light/dark color scheme as GTK via the xdg portal
  # (org.freedesktop.appearance, derived from org.gnome.desktop.interface).
  # No kvantum (it crashed the Qt6 hyprland-share-picker), no per-theme config.
  environment.sessionVariables.QT_QPA_PLATFORMTHEME = "xdgdesktopportal";

  # SSH askpass - Wayland-compatible confirmation dialog for ssh-agent
  # OpenSSH 10.x sanitizes the agent environment, so SSH_ASKPASS must be
  # set system-wide via programs.ssh.askPassword (not just session vars)
  programs.ssh.askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";

  # UPower for battery/power monitoring (waybar's battery module reads it)
  services.upower.enable = lib.mkDefault true;

  # Security - PAM services for screen lockers
  security.pam.services.swaylock.fprintAuth = lib.mkDefault false;
  # Default: no pam_fprintd in the locker stacks. With hyprlock's own
  # fingerprint support off, PAM sits through the fingerprint timeout
  # before checking the typed password on every unlock. Hosts that want
  # finger unlock set fprintAuth = true; hyprlock.nix follows it and
  # then runs password and fingerprint in parallel.
  security.pam.services.hyprlock.fprintAuth = lib.mkDefault false;
  # Without this hyprlock's stack has no pam_gnome_keyring at all, so the login
  # keyring stays locked for the rest of the session once the screen locks. Only
  # a typed password feeds it: pam_fprintd is sufficient and sits ahead of
  # pam_gnome_keyring, so finger unlock still leaves the keyring closed.
  security.pam.services.hyprlock.enableGnomeKeyring = lib.mkDefault true;

  # Wayland env vars belong to the compositor module (the hyprland aspect),
  # not here: set globally they break the X11 sessions sox1x still offers.
}
# vim: set ts=2 sw=2 et ai list nu

