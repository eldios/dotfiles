{ pkgs, ... }:
{
  services.roon-server = {
    enable = true;
    openFirewall = true;
    package = pkgs.unstable.roon-server;
  };
}
