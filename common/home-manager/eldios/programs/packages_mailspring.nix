{ pkgs, ... }:
let
  mailspring = pkgs.unstable.mailspring.overrideAttrs (
    _finalAttrs: previousAttrs: {
      version = "1.17.4";
      src = pkgs.unstable.fetchurl {
        url = "https://github.com/Foundry376/Mailspring/releases/download/${_finalAttrs.version}/mailspring-${_finalAttrs.version}-amd64.deb";
        hash = "sha256-PHxe44yzX9Zz+fQu30kX9epLEeG3wqqVL3p5+ZHMmos=";
      };
      buildInputs = (previousAttrs.buildInputs or [ ]) ++ [
        pkgs.openssl
        pkgs.curl
      ];
      runtimeDependencies = (previousAttrs.runtimeDependencies or [ ]) ++ [
        pkgs.openssl
        pkgs.curl
      ];
    }
  );
in
{
  home.packages = [
    mailspring
  ];
}

# vim: set ts=2 sw=2 et ai list nu
