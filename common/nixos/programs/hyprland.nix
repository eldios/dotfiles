{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    # nixpkgs-unstable matches what Omarchy upstream ships (~v0.54.3+).
    # Required for newer community themes (layerrule { ... } block syntax, etc.).
    package = pkgs.unstable.hyprland;
    portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
  };
}
