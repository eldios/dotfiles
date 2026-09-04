# Theming

Desktop theming is driven by [riso](https://github.com/eldios/riso), which
renders a theme into one file per consumer, and by the Omarchy shell tree that
`modules/aspects/desktop/_hyprland/omarchy-shell.nix` assembles from the
`omarchy-quattro` input. The rendered theme lives under
`~/.local/state/riso/current/theme/`; `~/.local/state/omarchy` is a symlink to
the same tree for the Omarchy shell, which hardcodes that location.

## How it works

`riso-apply [theme] [desktop]` runs `riso theme set` with two template
directories: `~/.config/riso/themed` for local templates and the `default/themed`
tree of the Omarchy package. Themes come from `~/.config/riso/themes`, installed
by hand, plus riso's compiled-in fallback `plain`, which is what a clean machine
gets. Home Manager runs `riso-apply` on every activation, so a rebuild re-renders
the current theme.

Each consumer reads its fragment from `current/theme/`:

- **alacritty** imports `alacritty.toml`, then `~/.config/riso/overrides/alacritty.toml`; live reload.
- **ghostty** reads `ghostty.conf` through `config-file` and reloads on SIGUSR2.
- **kitty** includes `kitty.conf` and reloads on SIGUSR1.
- **rio** uses `theme = "omarchy"`, a symlink from `~/.config/rio/themes/omarchy.toml` to `rio.toml`.
- **waybar** imports `waybar.css`, then `~/.config/riso/overrides/waybar.css`; bar position and size come from `~/.config/riso/overrides/waybar-config.json`.
- **mako** includes `mako.ini`; **hyprlock** sources `hyprlock.conf` and shows `current/background`.
- **hyprland** loads `hyprland.lua` from the state tree, then applies the theme's `hyprland.conf` through `hyprlang_compat.lua`.
- **btop**, **DankMaterialShell**, **Caelestia** and **Noctalia** are pointed once at `btop.theme`, `dms.json`, `caelestia.json` and `noctalia.json` by activation hooks.

The override files are real files seeded once and never rewritten, so edits
survive both a theme switch and a rebuild. Fonts are set directly in each
module; they are not part of the theme.

## Switch theme

`SUPER + SHIFT + T` opens the theme picker (`riso-carousel`, a wrapper around
`riso theme set --gui`); `SUPER + SHIFT + B` does the same for backgrounds.
From a terminal:

```bash
omarchy-theme-set <theme-name>     # render, then notify every running consumer
riso-theme-menu                    # pick from `riso theme list` in walker
riso theme list
```

`omarchy-theme-set` is this repo's stand-in for the upstream script
(`modules/aspects/desktop/_hyprland/hypr/omarchy-theme-set.sh`): it calls
`riso-apply`, signals ghostty and kitty, reloads mako, touches the alacritty
override so open windows re-read the chain, and hands the colour scheme and the
wallpaper to whichever shell is running. `riso` on PATH is a wrapper that
carries the same hooks, so `riso theme set <name>` from a terminal applies
fully as well.

## Desktop stacks

Every shell is installed and exactly one runs, so switching is a matter of
stopping processes, not rebuilding
(`modules/aspects/desktop/_hyprland/hypr/desktop-switch.sh`):

```bash
desktop-switch classic     # waybar + walker + mako + swayosd, wallpaper via swaybg
desktop-switch omarchy     # Omarchy 4, one Quickshell process
desktop-switch dms         # DankMaterialShell
desktop-switch caelestia   # Caelestia
desktop-switch noctalia    # Noctalia
desktop-switch retheme     # re-apply the theme to the running stack
desktop-switch current     # which one is running
desktop-switch list        # which ones are installed
```

The choice is written to `~/.local/state/desktop-stack`; the Hyprland
autostart reads it at login (`classic` when unset) and runs `retheme` once the
shell is up. A switch that cannot start its target falls back to the first
installed stack rather than leaving the screen bare.

Monitor layouts are per host, declared through `desktop.hyprland.monitors` in
the host's Home Manager fragment and emitted as Lua for the session.
