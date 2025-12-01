{

  imports = [

    ../../../common/home-manager/eldios/style/stylix.nix

    ../../../common/home-manager/eldios/services.nix
    ../../../common/home-manager/eldios/sops.nix

    ../../../common/home-manager/eldios/programs/neovim.nix
    ../../../common/home-manager/eldios/programs/mcp-servers.nix
    ../../../common/home-manager/eldios/programs/zellij.nix

    ../../../common/home-manager/eldios/programs/zsh.nix
    ../../../common/home-manager/eldios/programs/nushell.nix

    ../../../common/home-manager/eldios/programs/atuin.nix

    ../../../common/home-manager/eldios/programs/ssh.nix
    ../../../common/home-manager/eldios/programs/ssh-agents.nix

    ../../../common/home-manager/eldios/programs/alacritty.nix
    ../../../common/home-manager/eldios/programs/ghostty.nix
    ../../../common/home-manager/eldios/programs/kitty.nix
    ../../../common/home-manager/eldios/programs/kitty.nix
    ../../../common/home-manager/eldios/programs/niri.nix
    ../../../common/home-manager/eldios/programs/rio.nix
    ../../../common/home-manager/eldios/programs/rofi.nix
    ../../../common/home-manager/eldios/programs/wezterm.nix
    ../../../common/home-manager/eldios/programs/tmux.nix

    ../../../common/home-manager/eldios/programs/firefox.nix

    ../../../common/home-manager/eldios/programs/git.nix
    ../../../common/home-manager/eldios/programs/keybase.nix

    ../../../common/home-manager/eldios/programs/var.nix

    ../../../common/home-manager/eldios/programs/packages_common_cli.nix # common packages needed everywhere - CLI version
    ../../../common/home-manager/eldios/programs/packages_common_gui.nix # common packages needed everywhere - GUI version

    ../../../common/home-manager/eldios/programs/packages_linux_cli.nix # common packages needed on Linux - CLI version
    ../../../common/home-manager/eldios/programs/packages_linux_gui.nix # common packages needed on Linux - GUI version

  ];

} # EOF
# vim: set ts=2 sw=2 et ai list nu
