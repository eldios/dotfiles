# Steam with Proton GE.
{
  den.aspects.gaming.nixos = {pkgs, ...}: {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };
  };
}
