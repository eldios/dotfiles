{...}: {
  # Walker (v2.x) configuration. Schema matches upstream Omarchy
  # (github:basecamp/omarchy/config/walker/config.toml) so the launcher
  # finds providers via Elephant and applies the eldios theme.
  home.file.".config/walker/config.toml" = {
    text = ''
      force_keyboard_focus = true
      selection_wrap = true
      theme = "eldios"
      hide_action_hints = true

      [placeholders]
      "default" = { input = " Search...", list = "No Results" }

      [keybinds]
      quick_activate = []

      [columns]
      symbols = 1

      [providers]
      max_results = 256
      default = [
        "desktopapplications",
        "websearch",
      ]

      [[providers.prefixes]]
      prefix = "/"
      provider = "providerlist"

      [[providers.prefixes]]
      prefix = "."
      provider = "files"

      [[providers.prefixes]]
      prefix = ":"
      provider = "symbols"

      [[providers.prefixes]]
      prefix = "="
      provider = "calc"

      [[providers.prefixes]]
      prefix = "@"
      provider = "websearch"

      [[providers.prefixes]]
      prefix = "$"
      provider = "clipboard"
    '';
  };

  # Walker CSS pulls colors from current theme via @import of
  # ~/.config/omarchy/current/theme/walker.css (managed in omarchy-runtime.nix).
}
# vim: set ts=2 sw=2 et ai list nu
