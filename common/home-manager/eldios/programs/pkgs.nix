{ pkgs, ... }:
{
  # Neovim configuration deps
  home = {
    packages = with pkgs; [
      # Golang
      go
      # Rust
      # rustup
      cargo
      rustc
      rustfmt
      # Haskell
      ghc
      # vars
      ripgrep
      ripgrep-all
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
