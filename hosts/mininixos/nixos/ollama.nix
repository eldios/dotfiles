# Ollama LLM server for mininixos
# Accessible on all interfaces (LAN + Tailscale) via port 11434

{ ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    host = "0.0.0.0";
    openFirewall = true;

    # Radeon AI PRO R9700 (RDNA 4, Navi 48, 1002:7551) = gfx1201
    # ROCm 6.4 has experimental gfx12 support — override if auto-detection fails
    rocmOverrideGfx = "12.0.1";

    environmentVariables = {
      # Only expose the discrete R9700 (GPU 0, PCI 0000:03:00.0)
      # The Raphael iGPU (610M, 2 CU) causes page faults and GPU resets under compute load,
      # which corrupts /dev/kfd and takes down ROCm for ALL GPUs
      HIP_VISIBLE_DEVICES = "0";
    };

    loadModels = [
      "nomic-embed-text"
      "qwen2.5:32b"
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
