# The Hyprland session: the compositor from NixOS, and in the home the Lua
# config tree under _hyprland/hypr, the Omarchy 4 shell with the other
# Quickshell desktops desktop-switch can hand the screen to, and hyprlock.
# Monitors are declared per host through desktop.hyprland.monitors, an
# option omarchy-shell.nix declares.
{den, ...}: {
  den.aspects.hyprland = {
    # Portals, keyring and PAM stacks the session relies on.
    includes = [den.aspects.desktop-gui];

    nixos.imports = [./_hyprland/nixos.nix];

    homeManager.imports = [
      ./_hyprland/hyprland.nix
      ./_hyprland/omarchy-shell.nix
      ./_hyprland/hyprlock.nix
    ];
  };
}
