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
  appflowy = unstablePkgs.appflowy.overrideAttrs (_finalAttrs: _previousAttrs: {
    version = "v0.6.8";
  });
  patchelfFixes = pkgs.patchelfUnstable.overrideAttrs (_finalAttrs: _previousAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "Patryk27";
      repo = "patchelf";
      rev = "527926dd9d7f1468aa12f56afe6dcc976941fedb";
      sha256 = "sha256-3I089F2kgGMidR4hntxz5CKzZh5xoiUwUsUwLFUEXqE=";
    };
  });
  pcloud = pkgs.pcloud.overrideAttrs (_finalAttrs:previousAttrs: {
    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ patchelfFixes ];
  });
in
{
  home = {
    packages = with pkgs; [
      barrier
      davinci-resolve
      dbeaver
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
      appflowy
      davinci-resolve-studio
      pcloud
      inputs.zen-browser.packages."${system}".specific
    ];
  };
} # EOF
