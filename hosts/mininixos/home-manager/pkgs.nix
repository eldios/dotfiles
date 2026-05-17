{ pkgs, ... }:
{
  home = {
    packages = with pkgs.unstable; [
      # GPU server: this is the only host with the AMD GPU that runs the
      # Ollama server, so the ROCm-accelerated stack lives here, not in the
      # shared CLI package set.
      ollama-rocm
      llama-cpp-rocm
    ]; # EOM pkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
