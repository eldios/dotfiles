{ config, lib, pkgs, ... }:

let
  # Common options for all rofi modes
  common_opts = "-show-icons -fixed-num-lines -sorting-method fzf -drun-show-actions -sidebar-mode -steal-focus -window-thumbnail -auto-select";
in
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    # Use stylix for theming
    # Stylix will automatically apply the theme colors

    extraConfig = {
      modi = "drun,run,window,filebrowser";
      terminal = "${pkgs.ghostty}/bin/ghostty";
      show-icons = true;
      icon-theme = "Papirus";
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      disable-history = false;
      sort = true;
      sorting-method = "fzf";
      case-sensitive = false;
      cycle = true;
      sidebar-mode = true;
      auto-select = true;
      steal-focus = true;

      # Window thumbnails
      window-thumbnail = true;
      window-format = "{w} · {c} · {t}";
    };

    # Let Stylix handle the theme completely
    # Since stylix.targets.rofi.enable = true is set in stylix.nix,
    # Stylix will automatically generate and apply the theme

    # We only need to specify the structural elements
    # and let Stylix handle all the colors
    theme =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        # Window properties
        "window" = {
          transparency = "real";
          border = mkLiteral "2px";
          border-radius = mkLiteral "8px";
          width = 800;
          height = 500;
        };

        "mainbox" = {
          padding = mkLiteral "12px";
          spacing = mkLiteral "0px";
        };

        "inputbar" = {
          padding = mkLiteral "12px";
          spacing = mkLiteral "0px";
          children = map mkLiteral [ "prompt" "entry" ];
          border-radius = mkLiteral "8px";
        };

        "prompt" = {
          padding = mkLiteral "8px";
          font = mkLiteral "\"JetBrainsMono Nerd Font 12\"";
        };

        "entry" = {
          placeholder = "Search...";
          padding = mkLiteral "8px";
        };

        "listview" = {
          spacing = mkLiteral "4px";
          columns = 1;
          lines = 10;
          scrollbar = true;
          border = mkLiteral "0px";
          border-radius = mkLiteral "8px";
          padding = mkLiteral "8px 4px";
        };

        "element" = {
          padding = mkLiteral "8px 12px";
          spacing = mkLiteral "8px";
          border-radius = mkLiteral "4px";
        };

        "element-icon" = {
          size = mkLiteral "1.2em";
          vertical-align = mkLiteral "0.5";
        };

        "element-text" = {
          vertical-align = mkLiteral "0.5";
        };

        "scrollbar" = {
          handle-width = mkLiteral "4px";
          border-radius = mkLiteral "8px";
        };
      };
  };

  # Add animation support via picom/wayfire/hyprland
  # This will be handled by the respective window manager configs

  # Define common rofi commands for use in window manager configs
  home.sessionVariables = {
    ROFI_COMMON_OPTS = common_opts;
  };

  # Create helper scripts for different rofi modes
  home.packages = with pkgs; [
    (writeShellScriptBin "rofi-run" ''
      set -euo pipefail
      ${pkgs.rofi-wayland}/bin/rofi -show run ${common_opts} "$@"
    '')
    (writeShellScriptBin "rofi-drun" ''
      set -euo pipefail
      ${pkgs.rofi-wayland}/bin/rofi -show drun ${common_opts} "$@"
    '')
    (writeShellScriptBin "rofi-window" ''
      set -euo pipefail
      ${pkgs.rofi-wayland}/bin/rofi -show window ${common_opts} "$@"
    '')
    (writeShellScriptBin "rofi-filebrowser" ''
      set -euo pipefail
      ${pkgs.rofi-wayland}/bin/rofi -show filebrowser ${common_opts} "$@"
    '')
    # Additional dependency for better Rofi appearance
    papirus-icon-theme
  ];
}
