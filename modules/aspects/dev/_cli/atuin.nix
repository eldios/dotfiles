{inputs, ...}: {
  programs.atuin = {
    enable = true;

    daemon.enable = true;

    enableBashIntegration = true;
    enableFishIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    settings = {
      sync_address = (import "${inputs.secrets}/network.nix").atuinSyncUrl;
      sync_frequency = "15m";
    };
  };
}
