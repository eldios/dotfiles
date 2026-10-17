# 3D, game engine and video editing applications for the workstation and the
# laptop.
{
  den.aspects.media-production.homeManager = {pkgs, ...}: {
    home.packages = with pkgs.unstable; [
      blender
      godot
      godot-mcp
      davinci-resolve-studio
      kdePackages.kdenlive
    ];
  };
}
# EOF

