# The Hyprland session: the compositor from NixOS, and in the home the Lua
# config tree under _hyprland/hypr, the Omarchy 4 shell with every other
# desktop stack desktop-switch can hand the screen to, and the classic
# stack's own pieces (waybar, mako, hyprlock) configured rather than merely
# installed. Monitors are declared per host through
# desktop.hyprland.monitors, an option omarchy-shell.nix declares.
{den, ...}: {
  den.aspects.hyprland = {
    # Portals, keyring and PAM stacks the session relies on.
    includes = [den.aspects.desktop-gui];

    nixos.imports = [./_hyprland/nixos.nix];

    homeManager.imports = [
      ./_hyprland/hyprland.nix
      ./_hyprland/omarchy-shell.nix
      ./_hyprland/waybar.nix
      ./_hyprland/mako.nix
      ./_hyprland/hyprlock.nix
    ];
  };
}
