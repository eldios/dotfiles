{ pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  appflowy = unstablePkgs.appflowy.overrideAttrs (_finalAttrs: _previousAttrs: {
    version = "v0.6.8";
  });
  patchelfFixes = pkgs.patchelfUnstable.overrideAttrs (_finalAttrs: _previousAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "Patryk27";
      repo = "patchelf";
      rev = "527926dd9d7f1468aa12f56afe6dcc976941fedb";
      sha256 = "sha256-3I089F2kgGMidR4hntxz5CKzZh5xoiUwUsUwLFUEXqE=";
    };
  });
  pcloud = pkgs.pcloud.overrideAttrs (_finalAttrs:previousAttrs: {
    nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ patchelfFixes ];
  });
  mailspring = unstablePkgs.mailspring.overrideAttrs (_finalAttrs: _previousAttrs: {
    version = "1.14.0";
    src = unstablePkgs.fetchurl {
      url = "https://github.com/Foundry376/Mailspring/releases/download/${_finalAttrs.version}/mailspring-${_finalAttrs.version}-amd64.deb";
      hash = "sha256-ZpmL6d0QkHKKxn+KF1OEDeAb1bFp9uohBobCvblE+L8=";
    };
  });

  # obsidian - 2nd brain - patch taken from https://github.com/NixOS/nixpkgs/issues/273611
  #obsidian = lib.throwIf (lib.versionOlder "1.4.16" pkgs.obsidian.version) "Obsidian no longer requires EOL Electron" (
  #  pkgs.obsidian.override {
  #    electron = pkgs.electron_25.overrideAttrs (_: {
  #      preFixup = "patchelf --add-needed ${pkgs.libglvnd}/lib/libEGL.so.1 $out/bin/electron"; # NixOS/nixpkgs#272912
  #      meta.knownVulnerabilities = [ ]; # NixOS/nixpkgs#273611
  #    });
  #  }
  #);
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
    packages = (with pkgs; [
      # utils
      cava
      cavalier
      graphviz
      mission-center
      playerctl
      resources

      # GUI stuff
      alacritty # gpu accelerated terminal
      alacritty-theme # alacritty themes
      appimage-run
      arandr
      beeper
      cool-retro-term
      cryptomator
      discord
      easyeffects
      filezilla
      geoclue2
      gimp
      gparted
      gromit-mpx
      guardian-agent # Secure ssh-agent forwarding for Mosh and SSH
      inkscape
      kitty
      mosh
      mpv
      obs-studio
      openlens
      paperview
      pavucontrol
      pcmanfm
      redshift
      screenkey
      scribus
      signal-desktop
      slack
      spotify-unwrapped
      syncthing
      syncthing-cli
      syncthing-tray
      telegram-desktop
      unclutter # unclutter -idle 1 -root -grab -visible
      vlc
      vscode
      whatsapp-for-linux
      widevine-cdm
      xclip
      xdotool
      zathura
      zoom-us

      # 3D printing
      #super-slicer # FIXME: broken
      prusa-slicer
      cura
    ]) ++ (with unstablePkgs; [
      bitwarden
      brave
      #pdfposter # FIXME: broken
      variety
      vesktop # discord + some fixes
    ]) ++ (with unstablePkgs; [
      # 2nd Brain stuff
      cameractrls
      obsidian
      rnote
      streamcontroller
    ]) ++ [
      appflowy
      pcloud
      mailspring
    ];
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
