{ inputs, pkgs, nixpkgs-unstable, ... }:
let
  system = "x86_64-linux";
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  #davinci-resolve-studio = unstablePkgs.davinci-resolve-studio.override (old: {
  #  buildFHSEnv = a: (old.buildFHSEnv (a // {
  #    extraBwrapArgs = a.extraBwrapArgs ++ [
  #      "--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL"
  #    ];
  #  }));
  #});
in
{
  home = {
    packages = (with pkgs; [
      barrier
      davinci-resolve
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
      davinci-resolve-studio
    ]) ++ ([
      inputs.zen-browser.packages."${system}".specific
    ]);
  };
} # EOF
