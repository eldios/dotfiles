{ pkgs, ... }:
let
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
      davinci-resolve
      guvcview
      quickemu
      quickgui
      spice
      remmina
      uvcdynctrl
      vlc
    ] ++ [
      davinci-resolve-studio
    ];
  };
} # EOF
