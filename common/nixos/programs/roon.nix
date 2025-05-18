{ pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  services.roon-server = {
    enable = true;
    openFirewall = true;
    package = unstablePkgs.roon-server;
  };
}
