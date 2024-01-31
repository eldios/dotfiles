{ pkgs, home-manager, ... }:

{
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = "nix-command flakes";
  };

  environment.systemPackages = with pkgs; [
    nix
    home-manager
    util-linux
  ];

  programs.zsh.enable = true;  # default shell on catalina

  users.users.eldios = {
    home = "/Users/eldios";
    shell = pkgs.zsh;
  };

  imports =
    [
      # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix

      ./homebrew.nix

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.eldios = import ../home-manager/home.nix;
      }
    ];
}

# vim: set ts=2 sw=2 et ai list nu
