{pkgs, ...}: {
  home = {
    packages = (
      with pkgs.unstable; [
        blender
        davinci-resolve-studio
        kdePackages.kdenlive
      ]
    );
  };
}
# EOF

