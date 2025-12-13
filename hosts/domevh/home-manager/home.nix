{ ... }:
{
  programs = {
    home-manager = {
      enable = true;
    };
  };

  home = {
    stateVersion = "25.05"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion

    username = "eldios";
    homeDirectory = "/home/eldios";

    file = { };

    sessionVariables = {
      TERM = "xterm-256color";
    };
  };

  imports = [
    ./pkgs.nix
    ./common_programs.nix
    ./programs/git.nix
  ];
}

# vim: set ts=2 sw=2 et ai list nu
