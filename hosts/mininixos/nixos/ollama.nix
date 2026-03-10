# Ollama LLM server for mininixos
# Accessible on all interfaces (LAN + Tailscale) via port 11434

{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    host = "0.0.0.0";
    openFirewall = true;

    # RX 9700 XT AI PRO (RDNA 4, Navi 48) = gfx1201
    # ROCm 6.4 has experimental gfx12 support — override if auto-detection fails
    rocmOverrideGfx = "12.0.1";

    loadModels = [
      "nomic-embed-text"
      "qwen2.5:32b"
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
