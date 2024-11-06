{ pkgs, ... }:
# TODO: use sops - currently home-manager doesn't support sops-nix templates
#let
#  #secretspath = builtins.toString inputs.secrets;
#in
{
  programs.tmux = {
    enable = true;

    clock24 = true;

    extraConfig = ''
      set escape-time 1
    '';
  };

  # TODO: use sops - currently home-manager doesn't support sops-nix templates
  #sops = {
  #  secrets = {
  #    "keys/tmate/eldios/api-key" = {
  #      sopsFile = "${secretspath}/lele9iyoga.yaml";
  #    };
  #  };

  #  templates = {
  #    "keys-tmate-eldios-api-key".content = ''
  #      ${config.sops.placeholder."keys/tmate/eldios/api-key"}
  #    '';
  #  };
  #};

  home = {
    packages = with pkgs; [
      tmate
    ];

    # TODO: use sops - currently home-manager doesn't support sops-nix templates
    #file.".tmate.conf".text = ''
    #  set tmate-api.key ${config.sops.templates."keys-tmate-eldios-api-key".path};
    #  set tmate-session-name "eldios"
    #'';
  };
}
