# Packages for Linux-specific graphical user interface tools.
# This includes applications, theming, and services like gpg-agent.
{
  pkgs,
  winboat,
  ...
}:
let
  patchelfFixes = pkgs.patchelfUnstable.overrideAttrs (
    _finalAttrs: _previousAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "Patryk27";
        repo = "patchelf";
        rev = "527926dd9d7f1468aa12f56afe6dcc976941fedb";
        sha256 = "sha256-3I089F2kgGMidR4hntxz5CKzZh5xoiUwUsUwLFUEXqE=";
      };
    }
  );
  pcloud = pkgs.pcloud.overrideAttrs (
    _finalAttrs: previousAttrs: {
      nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ patchelfFixes ];
    }
  );
  mailspring = pkgs.unstable.mailspring.overrideAttrs (
    _finalAttrs: _previousAttrs: {
      version = "1.16.0";
      src = pkgs.unstable.fetchurl {
        url = "https://github.com/Foundry376/Mailspring/releases/download/${_finalAttrs.version}/mailspring-${_finalAttrs.version}-amd64.deb";
        hash = "sha256-iJ6VzwvNTIRqUq9OWNOWOSuLbqhx+Lqx584kuyIslyA=";
      };
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
    packages =
      (with pkgs; [
        # Utils
        cava
        cavalier
        graphviz
        mission-center
        playerctl
        resources

        # GUI Applications
        appimage-run
        arandr
        atop
        audacity
        barrier
        cameractrls
        cool-retro-term
        dia
        dive
        easyeffects
        filezilla
        freerdp
        gcal
        geoclue2
        gimp-with-plugins
        gparted
        graph-easy
        gromit-mpx
        guvcview
        inkscape
        kitty
        lens
        mpv
        obs-studio
        paperview
        pavucontrol
        pcmanfm
        pika-backup
        pulseaudio # to install tools like pactl
        quickgui
        redshift
        remmina
        screenkey
        scribus
        signal-desktop
        slack
        spice
        streamcontroller
        syncthing
        telegram-desktop
        unclutter # unclutter -idle 1 -root -grab -visible
        uqm
        uvcdynctrl
        vivaldi
        vivaldi-ffmpeg-codecs
        vlc
        whatsapp-for-linux
        widevine-cdm
        xclip
        xdotool
        zathura
        zoom-us

        # Handwriting and Notes
        krita
        saber
        styluslabs-write-bin
        write_stylus
        xournalpp
      ])
      ++ (with pkgs.unstable; [
        anytype
        beeper
        bitwarden
        brave
        cryptomator
        dbeaver-bin
        discord-canary
        spotify-unwrapped
        tidal-hifi
        variety
        vesktop # discord + some fixes
        vscode
        #pdfposter

        # 3D Printing
        #super-slicer
        prusa-slicer
        freecad-wayland

        # 2nd Brain stuff
        appflowy
        obsidian # Assuming the override is handled or not needed for now
        rnote

        # AI CLI tools
        opencode
        claude-code
        gemini-cli
      ])
      ++ [
        pcloud
        mailspring
        winboat.packages.${pkgs.system}.winboat
      ];
  }; # EOM home
}
# vim: set ts=2 sw=2 et ai list nu
