{ inputs, pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  davinci-resolve-studio = pkgs.davinci-resolve-studio.override (old: {
    buildFHSEnv = a: (old.buildFHSEnv (a // {
      extraBwrapArgs = a.extraBwrapArgs ++ [
        "--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL"
      ];
    }));
  });
in
{
  home = {
    packages = with pkgs; [
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
    ] ++ [
      davinci-resolve-studio
      inputs.zen-browser.packages."${system}".specific
    ] ++ (with unstablePkgs; [ ]);
  };
} # EOF
