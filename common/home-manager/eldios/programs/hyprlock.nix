{ pkgs, ... }:

let
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
in {
  home.packages = [ pkgs.hyprlock ];

  # Fallback color variables for omarchy themes that don't ship a hyprlock.conf
  # (e.g. robzee84, tokyoled). Sourced before the theme fragment so themes that
  # do provide their own colors override these.
  xdg.configFile."hypr/hyprlock-defaults.conf".text = ''
    $color = rgba(16, 19, 21, 1)
    $inner_color = rgba(16, 19, 21, 1)
    $outer_color = rgba(121, 129, 134, 1)
    $font_color = rgba(202, 204, 204, 1)
    $placeholder_color = rgba(202, 204, 204, 0.7)
    $check_color = rgba(52, 61, 65, 1)
  '';

  xdg.configFile."hypr/hyprlock.conf".text = ''
    source = ~/.config/hypr/hyprlock-defaults.conf
    source = ~/.config/omarchy/current/theme/hyprlock.conf

    general {
      ignore_empty_input = true
    }

    background {
      monitor =
      color = $color
      path = ~/.config/omarchy/current/background
      blur_passes = 3
    }

    animations {
      enabled = false
    }

    input-field {
      monitor =
      size = 650, 100
      position = 0, 0
      halign = center
      valign = center

      inner_color = $inner_color
      outer_color = $outer_color
      outline_thickness = 4

      font_family = JetBrainsMono Nerd Font
      font_color = $font_color

      placeholder_text = Enter Password
      check_color = $check_color
      fail_text = <i>$FAIL ($ATTEMPTS)</i>

      rounding = 0
      shadow_passes = 0
      fade_on_empty = false
    }

    auth {
      fingerprint:enabled = false
    }
  '';

  wayland.windowManager.hyprland.extraConfig = ''
    bind = $mod CTRL, Q, exec, ${hyprlock}
  '';
}
# vim: set ts=2 sw=2 et ai list nu
