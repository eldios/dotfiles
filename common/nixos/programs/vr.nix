{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    sidequest
  ];

  programs.alvr = {
    enable = true;
    #package = pkgs.unstable.alvr;
    package = pkgs.alvr;
    openFirewall = true;
  };
}
