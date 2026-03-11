# Ollama LLM server for mininixos
# Accessible on all interfaces (LAN + Tailscale) via port 11434

{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    host = "0.0.0.0";
    openFirewall = true;

    package = pkgs.unstable.ollama-rocm;

    # Radeon AI PRO R9700 (RDNA 4, Navi 48, 1002:7551) = gfx1201
    # ROCm 6.4 has experimental gfx12 support — override if auto-detection fails
    rocmOverrideGfx = "12.0.1";

    environmentVariables = {
      # Only expose the discrete R9700 (GPU 0, PCI 0000:03:00.0)
      # The Raphael iGPU (610M, 2 CU) causes page faults and GPU resets under compute load,
      # which corrupts /dev/kfd and takes down ROCm for ALL GPUs
      HIP_VISIBLE_DEVICES = "0";

      # gfx1201 reports VMM:no (no Virtual Memory Management in HIP runtime),
      # causing llama.cpp to be overly conservative with VRAM allocation (34/65 layers
      # offloaded despite 32GB free). These settings reduce memory pressure so more
      # layers fit on GPU:
      OLLAMA_FLASH_ATTENTION = "1"; # halves KV cache VRAM usage
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # quantized KV cache, further VRAM savings
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
