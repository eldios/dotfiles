# 3D and game engine applications for the workstation and the laptop.
{
  den.aspects.media-production.homeManager = {pkgs, ...}: {
    home.packages =
      [pkgs.unstable.blender]
      # Godot from the stable channel: on unstable an input update can leave
      # it unbuildable, and godot-mcp only needs Godot 4.4 or later.
      ++ (with pkgs; [
        godot
        godot-mcp
      ]);
  };
}
# EOF

