{ config, ... }:
let
  #repo_dir            = "${config.home.homeDirectory}/.dotfiles";
  repo_dir            = "/Users/eldios/.dotfiles";
  common_mods_dir     = "${repo_dir}/common";
  common_hm_dir       = "${common_mods_dir}/home-manager/eldios";
  common_programs_dir = "${common_hm_dir}/programs";
in
{

  imports = [

    "${common_programs_dir}/neovim.nix"
    "${common_programs_dir}/lunarvim.nix"
    "${common_programs_dir}/zellij.nix"

    "${common_programs_dir}/zsh.nix"

    "${common_programs_dir}/alacritty.nix"

    "${common_programs_dir}/git.nix"

    "${common_programs_dir}/yabai.nix"

    "${common_programs_dir}/var.nix" # various home manager programs with specific configuration

    "${common_programs_dir}/pkgs_cli.nix" # common packages needed everywhere - CLI version
    "${common_programs_dir}/pkgs_gui.nix" # common packages needed everywhere - GUI version

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
