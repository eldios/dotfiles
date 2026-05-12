{ ... }:
{
  # Sticking with nixpkgs stable Hyprland (0.52.1). Unstable (0.54.3) caused
  # silent crashes at session start with our current HM config — needs deeper
  # debug before bumping. Trade-off: third-party themes using `layerrule { ... }`
  # block syntax (introduced ~0.55+) will warn but won't break theming.
  programs.hyprland.enable = true;
}
