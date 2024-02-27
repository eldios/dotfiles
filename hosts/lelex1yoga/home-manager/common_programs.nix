{ config, ... }:
let
  #repo_dir            = "${config.home.homeDirectory}/.dotfiles";
  repo_dir            = "/home/eldios/.dotfiles";
  common_mods_dir     = "${repo_dir}/common";
  common_hm_dir       = "${common_mods_dir}/home-manager/eldios";
  common_programs_dir = "${common_hm_dir}/programs";
in rec
{

  imports = [

    "${common_programs_dir}/neovim.nix"
    "${common_programs_dir}/lunarvim.nix"
    "${common_programs_dir}/zellij.nix"

    "${common_programs_dir}/zsh.nix"

    "${common_programs_dir}/alacritty.nix"
    "${common_programs_dir}/kitty.nix"
    "${common_programs_dir}/wezterm.nix"

    "${common_programs_dir}/firefox.nix"

    "${common_programs_dir}/git.nix"

    "${common_programs_dir}/var.nix"

    "${common_programs_dir}/pkgs_cli.nix" # common packages needed everywhere - CLI version
    "${common_programs_dir}/pkgs_gui.nix" # common packages needed everywhere - GUI version

    "${common_programs_dir}/pkgs_linux_cli.nix" # common packages needed on Linux - CLI version
    "${common_programs_dir}/pkgs_linux_gui.nix" # common packages needed on Linux - GUI version

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
