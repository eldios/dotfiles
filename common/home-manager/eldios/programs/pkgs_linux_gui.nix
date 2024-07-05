{ lib, pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };

  # obsidian - 2nd brain - patch taken from https://github.com/NixOS/nixpkgs/issues/273611
  obsidian = lib.throwIf (lib.versionOlder "1.4.16" pkgs.obsidian.version) "Obsidian no longer requires EOL Electron" (
    pkgs.obsidian.override {
      electron = pkgs.electron_25.overrideAttrs (_: {
        preFixup = "patchelf --add-needed ${pkgs.libglvnd}/lib/libEGL.so.1 $out/bin/electron"; # NixOS/nixpkgs#272912
        meta.knownVulnerabilities = [ ]; # NixOS/nixpkgs#273611
      });
    }
  );
in
{
  services = {

    gpg-agent = {
      enable = true;

      enableSshSupport = false;
      enableZshIntegration = true;

      extraConfig = ''
        #debug-pinentry
        #debug ipc
        #debug-level 1024

        # I don't use smart cards
        disable-scdaemon

        pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses
      '';
    };
  }; # EOM services

  home = {
    packages = ([ obsidian ]) ++ (with pkgs; [
      # utils
      cava
      cavalier
      graphviz
      playerctl

      # GUI stuff
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      arandr
      beeper
      bitwarden
      brave
      cryptomator
      discord
      easyeffects
      geoclue2
      gimp
      inkscape
      kitty
      obs-studio
      openlens
      paperview
      pavucontrol
      pcmanfm
      redshift
      scribus
      signal-desktop
      slack
      spotify-unwrapped
      syncthing
      syncthing-cli
      syncthing-tray
      telegram-desktop
      vscode
      whatsapp-for-linux
      widevine-cdm
      xdotool
      zathura
      zoom-us

      # 3D printing
      super-slicer
      prusa-slicer
      cura
    ]) # EOM pkgs
      ++ (with unstablePkgs; [
      mailspring
      vesktop # discord + some fixes
      variety
    ]); # EOM unstablePkgs
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
