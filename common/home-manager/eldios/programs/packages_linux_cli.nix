{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      [
        atop
        barrier
        dive
        docker-slim
        gcal
        graph-easy
        guvcview
        iotop
        k3s
        lazydocker
        mosh
        ncdu
        networkmanager
        ntfs3g
        p7zip
        powertop
        quickemu
        remmina
        spice
        sshx
        tty-share
        uqm
        uvcdynctrl
        vlc
      ]
      ++ (with pkgs.unstable; [
        opencode
      ]);
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
