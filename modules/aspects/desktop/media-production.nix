# 3D and game engine applications for the workstation and the laptop.
{
  den.aspects.media-production.homeManager = {pkgs, ...}: {
    home.packages = with pkgs.unstable; [
      blender
      godot
      godot-mcp
    ];
  };
}
# EOF

