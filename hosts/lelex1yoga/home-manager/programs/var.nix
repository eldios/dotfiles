{ pkgs, ... }:
{
  # Decoratively fix virt-manager error: "Could not detect a default hypervisor" instead of imperitively through virt-manager's menubar > file > Add Connection
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  programs = {

    bash.enable = true;

    command-not-found.enable = false; # mutually exclusive with nix-index
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    dircolors.enable = true;
    eza.enable       = true;
    htop.enable      = true;
    info.enable      = true;
    jq.enable        = true;

    fzf = {
      enable = true;
      enableZshIntegration = true;
    }; # EOM zfz

    bat = {
      enable = true;
      config = {
        theme = "GitHub";
        italic-text = "always";
      };
    }; # EOM bat

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    }; # EOM direnv

  }; # EOM programs

} # EOF
# vim: set ts=2 sw=2 et ai list nu
