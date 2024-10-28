{ inputs, pkgs, nixpkgs-unstable, ... }:
let
  system = "x86_64-linux";
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  home = {
    packages = (with pkgs; [
      barrier
      dbeaver-bin
      guvcview
      quickemu
      quickgui
      remmina
      spice
      uqm
      uvcdynctrl
      vlc
      wine
    ]) ++ (with unstablePkgs; [
      audacity
    ]) ++ ([
      inputs.zen-browser.packages."${system}".specific
    ]);
  };
} # EOF
