# Shared desktop/laptop GUI configuration
# Common settings for graphical systems (bluetooth, XDG portal, security, etc.)
{ pkgs, lib, ... }:
{
  # Bluetooth
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
      common.default = [ "gtk" ];
      hyprland.default = [
        "gtk"
        "hyprland"
      ];
      sway.default = [
        "gtk"
        "wlr"
        "luminous"
      ];
      niri.default = [
        "gtk"
        "gnome"
      ];
    };
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-luminous
      pkgs.xdg-desktop-portal-wlr
    ];
  };

  # D-Bus for XDG portal
  services.dbus.enable = true;

  # GNOME keyring for secrets
  services.gnome.gnome-keyring.enable = lib.mkDefault true;

  # GVfs for file manager support
  services.gvfs.enable = lib.mkDefault true;

  # Security - PAM services for screen lockers
  security.pam.services.swaylock = { };

  # Wayland env vars are set per-compositor (hyprland.nix, wayfire.nix, etc.)
  # Don't set them globally - breaks X11 sessions like i3
}

# vim: set ts=2 sw=2 et ai list nu
