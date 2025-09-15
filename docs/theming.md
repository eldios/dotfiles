# Theming

Using Stylix for consistent colors everywhere.

## Current Theme

Neon dark:
- Base: #0a0e27
- Accent: #00d9ff (cyan)
- Secondary: #bb9af7 (purple)

## Config

`common/themes/stylix.nix`

## Change Theme

```nix
# Wallpaper
stylix.image = ./wallpaper.jpg;

# Scheme
stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";

# Disable for specific app
stylix.targets.firefox.enable = false;
```

## Manual Configs

- Discord: `common/files/discord/`
- Firefox: userChrome.css