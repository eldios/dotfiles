{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;

    clock24 = true;

    extraConfig = ''
      set escape-time 1
    '';
  };

  home = {
    packages = with pkgs; [
      tmate
    ];
  };
}
