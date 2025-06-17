{
  programs.atuin = {
    enable = true;

    daemon.enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    settings = {
      sync_address = "https://history.example.invalid";
      sync_frequency = "15m";
    };
  };
}

