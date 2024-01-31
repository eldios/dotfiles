{ pkgs, ... }:
{
  homebrew = {
    enable = true;

    onActivation.upgrade = true;

    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    casks = [
      "hammerspoon"
      "amethyst"
      "alfred"
      "logseq"
      "rectangle"
      "iina"
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
