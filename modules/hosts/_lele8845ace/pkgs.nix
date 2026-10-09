{pkgs, ...}: {
  home = {
    packages = (
      with pkgs.unstable; [
        blender
        godot
        godot-mcp
        davinci-resolve-studio
        kdePackages.kdenlive
      ]
    );
  };
}
# EOF

