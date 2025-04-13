{ pkgs, nixpkgs-unstable, ... }:
let
  unstablePkgs = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
  #appflowy = unstablePkgs.appflowy.overrideAttrs (_finalAttrs: _previousAttrs: {
  #  version = "0.8.8";
  #  src = unstablePkgs.fetchzip {
  #    url = "https://github.com/AppFlowy-IO/appflowy/releases/download/${_finalAttrs.version}/AppFlowy-${_finalAttrs.version}-linux-x86_64.tar.gz";
  #    hash = "sha256-n190ErYfhYbJ0Yxb+7dhIDqTtA0Nk03uAWzjPI+G1qk=";
  #    stripRoot = false;
  #  };
  #});
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
    version = "1.15.1";
    src = unstablePkgs.fetchurl {
      url = "https://github.com/Foundry376/Mailspring/releases/download/${_finalAttrs.version}/mailspring-${_finalAttrs.version}-amd64.deb";
      hash = "sha256-+glQaz36mKMtnNeyHH4brZmzYe9SHCtccO6CIJpTH2k=";
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
      cool-retro-term
      discord
      easyeffects
      filezilla
      geoclue2
      gimp-with-plugins
      gparted
      gromit-mpx
      inkscape
      kitty
      mosh
      mpv
      obs-studio
      lens
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

      # handwriting and notes
      krita
      saber
      styluslabs-write-bin
      write_stylus
      xournalpp

      # 3D printing
      prusa-slicer
      #cura
    ]) ++ (with unstablePkgs; [
      beeper
      bitwarden
      brave
      cryptomator
      variety
      vesktop # discord + some fixes
      vivaldi
      vivaldi-ffmpeg-codecs
      #super-slicer
      #pdfposter
    ]) ++ (with unstablePkgs; [
      # 2nd Brain stuff
      appflowy
      cameractrls
      obsidian
      rnote
      streamcontroller
    ]) ++ [
      pcloud
      mailspring
    ];
  }; # EOM home
}

# vim: set ts=2 sw=2 et ai list nu
