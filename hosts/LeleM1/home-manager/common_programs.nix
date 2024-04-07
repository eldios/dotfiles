{

  imports = [

    ../../../common/home-manager/eldios/services.nix

    ../../../common/home-manager/eldios/programs/neovim.nix
    ../../../common/home-manager/eldios/programs/lunarvim.nix
    ../../../common/home-manager/eldios/programs/zellij.nix

    ../../../common/home-manager/eldios/programs/zsh.nix

    ../../../common/home-manager/eldios/programs/ssh.nix

    ../../../common/home-manager/eldios/programs/alacritty.nix

    ../../../common/home-manager/eldios/programs/git.nix

    ../../../common/home-manager/eldios/programs/yabai.nix

    ../../../common/home-manager/eldios/programs/var.nix # various home manager programs with specific configuration

    ../../../common/home-manager/eldios/programs/pkgs_cli.nix # common packages needed everywhere - CLI version
    ../../../common/home-manager/eldios/programs/pkgs_gui.nix # common packages needed everywhere - GUI version

    ../../../common/home-manager/eldios/programs/pkgs_darwin_cli.nix # common packages needed everywhere - MacOS CLI version
    ../../../common/home-manager/eldios/programs/pkgs_darwin_gui.nix # common packages needed everywhere - MacOS GUI version
  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
