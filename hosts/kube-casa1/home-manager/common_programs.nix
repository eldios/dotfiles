{

  imports = [

    ../../../common/home-manager/eldios/services.nix
    ../../../common/home-manager/eldios/sops.nix

    ../../../common/home-manager/eldios/programs/neovim.nix
    ../../../common/home-manager/eldios/programs/mcp-servers.nix
    ../../../common/home-manager/eldios/programs/zellij.nix

    ../../../common/home-manager/eldios/programs/zsh.nix

    ../../../common/home-manager/eldios/programs/ssh.nix

    ../../../common/home-manager/eldios/programs/git.nix

    ../../../common/home-manager/eldios/programs/var.nix

    ../../../common/home-manager/eldios/programs/packages_common_cli.nix # common packages needed everywhere - CLI version

    ../../../common/home-manager/eldios/programs/packages_linux_cli.nix # common packages needed on Linux - CLI version

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
