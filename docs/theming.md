# Theming

Desktop theming is driven entirely by **omarchy**. The active theme lives under
`~/.config/omarchy/current/theme/`, and each app reads its palette from there:
waybar, walker, mako, btop, hyprland, hyprlock, and the terminals ghostty, kitty,
rio.

## How it works

`omarchy-theme-set <name>` renders every template in
`common/omarchy/default/themed/*.tpl` — substituting the theme's `colors.toml`
values (`{{ background }}`, `{{ color0 }}`, …) — into
`~/.config/omarchy/current/theme/<file>`. Each app then consumes its rendered
file:

- **ghostty / kitty** — `config-file` include of `current/theme/{ghostty.conf,kitty.conf}`.
- **rio** — `theme = "omarchy"` → `~/.config/rio/themes/omarchy.toml` (symlink to `current/theme/rio.toml`).
- **hyprland** — `source`s `current/theme/hyprland.conf` (window borders, groupbar colors).

Fonts are set directly in each module — they are not part of the color theme.

## Layout

- `common/omarchy/` — Nix-side overrides layered on the upstream omarchy input:
  custom `bin/` scripts, `default/` configs (including `themed/*.tpl`), theme-set
  `hooks/`, and the `menu.sh` extension. Wired into `~/.config/omarchy` and
  `~/.local/share/omarchy/default` by the home-manager modules
  `common/home-manager/eldios/programs/omarchy.nix` and `omarchy-runtime.nix`.

## Switch theme

Use the omarchy menu (theme submenu) or the CLI:

```bash
omarchy-theme-set <theme-name>
```

The first-run seed theme is `hyprland-fancy` (see `defaultTheme` in
`omarchy-runtime.nix`).

## Aesthetic tweaks

High-impact overrides (rounding, opacity, blur, gaps, animations, shadow,
waybar shape/position) are applied on top of the current theme:

```bash
omarchy-aesthetic-set <rounding|opacity|blur|animations|gaps|shadow|waybar|waybar_position> <value|default>
```

`<key> default` removes the override. Prefer the menu over editing state by hand.
