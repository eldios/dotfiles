# VR streaming to a standalone headset: ALVR server and SideQuest.
{
  den.aspects.vr = {
    nixos.imports = [./_vr/vr.nix];
  };
}
