# common/nixos/theme.nix
{ inputs, ... }: # Removed pkgs, lib, stylix, config as direct inputs if not used

{
  # This file primarily ensures that the Stylix NixOS module is available
  # if any system-wide Stylix configurations were ever needed.
  # The main theming logic is now handled by the Home Manager stylix.nix module.
  imports = [
    inputs.stylix.nixosModules.stylix # Import the main Stylix NixOS module
  ];

  # Minimal system-level Stylix config, could be empty if HM handles all.
  stylix.enable = true; # Enable stylix system-wide components (e.g. dconf, fonts)
                        # This also makes config.lib.stylix.colors available to NixOS modules.
}
