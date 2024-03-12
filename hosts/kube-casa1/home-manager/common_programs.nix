{ config, ... }:
let
  #repo_dir            = "${config.home.homeDirectory}/.dotfiles";
  repo_dir            = "/data/dotfiles";
  common_mods_dir     = "${repo_dir}/common";
  common_hm_dir       = "${common_mods_dir}/home-manager/eldios";
  common_programs_dir = "${common_hm_dir}/programs";
in rec
{

  imports = [

    "${common_programs_dir}/neovim.nix"
    "${common_programs_dir}/zellij.nix"

    "${common_programs_dir}/zsh.nix"

    "${common_programs_dir}/git.nix"

    "${common_programs_dir}/var.nix"

    "${common_programs_dir}/pkgs_cli.nix" # common packages needed everywhere - CLI version

    "${common_programs_dir}/pkgs_linux_cli.nix" # common packages needed on Linux - CLI version

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
