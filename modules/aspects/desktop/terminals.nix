# Terminal emulators, plus the shell and multiplexer that only make sense
# inside one: nushell and tmux. Each emulator reads its palette from the
# theme riso renders, so a theme switch repaints every open window.
{
  den.aspects.terminals = {
    homeManager.imports = [
      ./_terminals/alacritty.nix
      ./_terminals/ghostty.nix
      ./_terminals/kitty.nix
      ./_terminals/rio.nix
      ./_terminals/wezterm.nix
      ./_terminals/nushell.nix
      ./_terminals/tmux.nix
    ];
  };
}
