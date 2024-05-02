{
  programs.tmux = {
    enable = true;

    clock24 = true;

    extraConfig = ''
      set escpate-time 1
    '';
  };
}
