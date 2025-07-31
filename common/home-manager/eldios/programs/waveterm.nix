{ config, ... }:
{
  programs = {
    waveterm = {
      enable = true;

      settings = {
        # Auto-update settings
        "autoupdate:channel" = "latest";
        "autoupdate:enabled" = false;

        # App settings
        "app:dismissarchitecturewarning" = false;

        # Terminal settings using Stylix configuration
        "term:localshellpath" = "/run/current-system/sw/bin/zsh";
        "term:theme" = "stylix-theme";
        "term:fontsize" = config.stylix.fonts.sizes.terminal;
        "term:fontfamily" = config.stylix.fonts.monospace.name;
        "term:scrollback" = 10000;
        "term:cursorblink" = true;
        "term:cursorstyle" = "block";
        "term:copyonselect" = true;
        "term:pasteonrightclick" = true;
        "term:smoothscroll" = true;
        "term:scrollspeed" = 1;
        "term:backgroundopacity" = 0.95;

        # Widget settings
        "widget:showhelp" = true;
        "widget:sidebarwidth" = 300;
        "widget:autocollapse" = false;

        # Tab settings
        "tab:preset" = "default";
        "tab:showtabbar" = true;
        "tab:showwindowcontrols" = false;
        "tab:autoclosetabs" = false;
        "tab:maxtabs" = 10;

        # Connection settings
        "conn:defaultsshport" = 22;
        "conn:sshkeepalive" = 60;
        "conn:timeout" = 30;
        "conn:shellpath" = "/run/current-system/sw/bin/zsh";

        # AI settings
        "ai:defaultprovider" = "ai@claude-sonnet-4";
        "ai:defaultmodel" = "";
        "ai:streaming" = true;

        # Privacy settings
        "telemetry:enabled" = false;
        "telemetry:crashreports" = false;

        # Development settings
        "dev:debug" = false;
        "dev:verbose" = false;
        "dev:experimentalfeatures" = true;
      };

      # Define a custom Stylix theme based on the current color scheme
      themes = {
        "stylix-theme" = {
          "display:name" = "Stylix Theme";
          "display:order" = 1;
          background = "#${config.lib.stylix.colors.base00}";
          foreground = "#${config.lib.stylix.colors.base05}";
          cursorAccent = "#${config.lib.stylix.colors.base05}";
          selectionBackground = "#${config.lib.stylix.colors.base02}";

          # Standard colors
          black = "#${config.lib.stylix.colors.base00}";
          red = "#${config.lib.stylix.colors.base08}";
          green = "#${config.lib.stylix.colors.base0B}";
          yellow = "#${config.lib.stylix.colors.base0A}";
          blue = "#${config.lib.stylix.colors.base0D}";
          magenta = "#${config.lib.stylix.colors.base0E}";
          cyan = "#${config.lib.stylix.colors.base0C}";
          white = "#${config.lib.stylix.colors.base05}";
          gray = "#${config.lib.stylix.colors.base03}";

          # Bright colors
          brightBlack = "#${config.lib.stylix.colors.base03}";
          brightRed = "#${config.lib.stylix.colors.base08}";
          brightGreen = "#${config.lib.stylix.colors.base0B}";
          brightYellow = "#${config.lib.stylix.colors.base0A}";
          brightBlue = "#${config.lib.stylix.colors.base0D}";
          brightMagenta = "#${config.lib.stylix.colors.base0E}";
          brightCyan = "#${config.lib.stylix.colors.base0C}";
          brightWhite = "#${config.lib.stylix.colors.base07}";

          # Command text color
          cmdtext = "#${config.lib.stylix.colors.base05}";
        };
      };

    };
  };

  # AI providers configuration file for WaveTerm
  xdg.configFile."waveterm/presets/ai.json".source = ./waveterm-ai-providers.json;
}
