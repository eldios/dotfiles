# den wiring shared by every host, user and home.
{
  inputs,
  den,
  lib,
  ...
}: let
  # What every NixOS and Home Manager module receives as arguments. Anything
  # else from the flake is reached as `inputs.<name>`.
  specialArgs = {
    inherit inputs;
    inherit (inputs) nixpkgs nixpkgs-unstable home-manager nixos-hardware;
  };
in {
  imports = [inputs.den.flakeModule];

  # Every user gets a Home Manager environment unless it opts out.
  den.schema.user.classes = lib.mkDefault ["homeManager"];

  # Hosts build with the same argument set the modules were written against.
  den.schema.host.instantiate = args:
    inputs.nixpkgs.lib.nixosSystem (args // {inherit specialArgs;});

  den.default = {
    includes = [den.batteries.hostname];

    nixos = {
      home-manager = {
        backupFileExtension = "hm-backup";
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [inputs.sops-nix.homeManagerModules.sops];
        extraSpecialArgs = specialArgs;
      };
    };

    homeManager = {
      programs.home-manager.enable = true;
      home.stateVersion = "25.11"; # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    };
  };
}
