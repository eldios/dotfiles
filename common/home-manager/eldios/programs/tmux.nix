{
  programs.tmux = {
    enable = true;

    clock24 = true;

    extraConfig = ''
      set escape-time 1
    '';
  };
}
