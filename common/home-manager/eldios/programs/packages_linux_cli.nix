# Packages for Linux-specific command-line interface tools.
{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      [
        atop
        dive
        docker-slim
        gcal
        graph-easy
        iotop
        k3s
        lazydocker
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
        claude-code
        gemini-cli
      ]);
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
