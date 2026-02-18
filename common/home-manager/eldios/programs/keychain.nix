{
  programs.keychain = {
    enable = true;
    keys = [
      "id_ed25519" # main SSH key
      "AA6BC7743F8F9AD84BBA15C72CCBF4B71EFFDD46" # main GPG key
    ];
    enableZshIntegration = true;
    enableNushellIntegration = true;
    extraFlags = [
      "--quiet"
      "--clear"
      "--timeout"
      "480"
      "--confirm"
    ];
  };
} # EOF
# vim: set ts=2 sw=2 et ai list nu
