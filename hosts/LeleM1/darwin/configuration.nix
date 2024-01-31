{ pkgs, home-manager, ... }:

{
  nixpkgs.config.allowUnfree = true;

  services.nix-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    home-manager
  ];

  users.users.eldios = {
    home = "/Users/eldios";
    shell = pkgs.zsh;
    description = "Devin Singh";
  };

  imports =
    [
      # select hardware from https://github.com/NixOS/nixos-hardware/blob/master/flake.nix

      #./homebrew.nix

      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.eldios = import ../home-manager/home.nix;
      }
    ];
}

# vim: set ts=2 sw=2 et ai list nu
