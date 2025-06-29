# Packages for Linux-specific command-line interface tools.
{ pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = pkgs.system; # Use the system from the main pkgs
    config.allowUnfree = true;
  };
in
{
  home = {
    packages = with pkgs; [
      atop
      dive
      docker-slim
      gcal
      graph-easy
      iotop
      k3s
      lazydocker
      ncdu
      networkmanager
      ntfs3g
      p7zip
      powertop
      quickemu
      sshx
      tty-share
    ] ++ (with unstablePkgs; [
      claude-code
    ]);
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
