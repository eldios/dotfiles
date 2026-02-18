{
  programs.keychain = {
    enable = true;
    keys = [ "id_ed25519" ];
    enableZshIntegration = true;
    enableNushellIntegration = true;
    extraFlags = [
      "--quiet"
      "--clear"
      "--timeout" "480"
      "--confirm"
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
