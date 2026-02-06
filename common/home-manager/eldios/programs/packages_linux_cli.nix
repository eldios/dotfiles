{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      [
        atop
        docker-slim
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
        sshx
        tty-share
      ]
      ++ (with pkgs.unstable; [
        opencode
      ]);
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
