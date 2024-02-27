{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # deps
      libiconv
<<<<<<< Updated upstream

      # DevOps stuff
      docker
      terraform
      opentofu

      # Kubernetes stuff
      datree
      k8sgpt
      k9s
      kubernetes-helm
      kdash
      kind
      ktop
      kubectl
      kubectx

      # fonts
      anonymousPro
      corefonts
      fira-code-nerdfont
      font-awesome
      meslo-lgs-nf
      nerdfonts
=======
>>>>>>> Stashed changes
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
