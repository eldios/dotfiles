{

  imports = [

    ../../../common/home-manager/eldios/programs/neovim.nix
    ../../../common/home-manager/eldios/programs/lunarvim.nix
    ../../../common/home-manager/eldios/programs/zellij.nix

    ../../../common/home-manager/eldios/programs/zsh.nix

    ../../../common/home-manager/eldios/programs/alacritty.nix
    ../../../common/home-manager/eldios/programs/kitty.nix
    ../../../common/home-manager/eldios/programs/wezterm.nix

    ../../../common/home-manager/eldios/programs/firefox.nix

    ../../../common/home-manager/eldios/programs/git.nix

    ../../../common/home-manager/eldios/programs/var.nix

    ../../../common/home-manager/eldios/programs/pkgs_cli.nix # common packages needed everywhere - CLI version
    ../../../common/home-manager/eldios/programs/pkgs_gui.nix # common packages needed everywhere - GUI version

    ../../../common/home-manager/eldios/programs/pkgs_linux_cli.nix # common packages needed on Linux - CLI version
    ../../../common/home-manager/eldios/programs/pkgs_linux_gui.nix # common packages needed on Linux - GUI version

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
