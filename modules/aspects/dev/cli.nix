# The shell environment every host gets, headless ones included: zsh with
# its prompt and completions, shell history sync, the small always-on
# programs and the CLI package set.
{
  den.aspects.cli = {
    homeManager.imports = [
      ./_cli/zsh.nix
      ./_cli/atuin.nix
      ./_cli/misc.nix
      ./_cli/yazi.nix
      ./_cli/packages_common_cli.nix
      ./_cli/packages_linux_cli.nix
    ];
  };
}
