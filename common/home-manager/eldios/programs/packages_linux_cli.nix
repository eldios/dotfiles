# Packages for Linux-specific command-line interface tools.
{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      [
        # System Monitoring
        atop # advanced system and process monitor
        iotop # I/O usage monitor per process
        powertop # power consumption analyzer

        # Containers & Kubernetes
        docker-slim # optimize and shrink Docker images
        k3s # lightweight Kubernetes distribution
        lazydocker # TUI for Docker management

        # Networking & Remote
        mosh # mobile shell, robust SSH alternative
        networkmanager # network connection manager
        sshx # collaborative terminal sharing
        tty-share # share terminal over the web

        # Disk & Filesystem
        ncdu # disk usage analyzer with TUI
        ntfs3g # NTFS filesystem read/write support
        p7zip # 7-Zip archive tool

        # Virtualization
        quickemu # quick QEMU VM manager
      ]
      ++ (with pkgs.unstable; [
        # AI Tools
        opencode # AI coding assistant TUI
      ]);
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
