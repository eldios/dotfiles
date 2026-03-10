# Ollama LLM server for lele8845ace (desktop/gaming workstation)
# Resource-limited to avoid starving UI and games of RAM/VRAM

{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    host = "0.0.0.0";
    openFirewall = true;

    environmentVariables = {
      # Keep resource usage low — this machine runs desktop UI and Steam
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_NUM_PARALLEL = "1";
      OLLAMA_KEEP_ALIVE = "5m"; # unload models after 5min idle to free VRAM
    };

    loadModels = [
      "nomic-embed-text"
      "qwen2.5:14b"
    ];
  };

  # Cap system memory usage so desktop/games stay responsive
  systemd.services.ollama.serviceConfig = {
    MemoryHigh = "8G";
    MemoryMax = "12G";
  };
}

# vim: set ts=2 sw=2 et ai list nu
