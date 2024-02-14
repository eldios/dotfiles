{ config, ... }:
let
  repo_dir            = "${config.home.homeDirectory}/.dotfiles";
  common_mods_dir     = "${repo_dir}/common";
  common_hm_dir       = "${common_mods_dir}/home-manager/eldios";
  common_programs_dir = "${common_hm_dir}/programs";
in
{

  imports = [

    "${common_programs_dir}/neovim.nix"
    "${common_programs_dir}/zellij.nix"
    "${common_programs_dir}/zsh.nix"

    "${common_programs_dir}/alacritty.nix"

    "${common_programs_dir}/git.nix"

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
