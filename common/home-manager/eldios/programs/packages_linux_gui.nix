# Packages for Linux-specific graphical user interface tools.
# This includes applications, theming, and services like gpg-agent.
{
  pkgs,
  ...
}:
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
        audacity
        input-leap
        cameractrls
        cool-retro-term
        cryptomator
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
        vorta
        wasistlos
        widevine-cdm
        xclip
        xdotool
        zathura
        zed-editor
        zoom-us

        # Handwriting and Notes
        krita
        saber
        styluslabs-write-bin
        xournalpp
      ])
      ++ (with pkgs.unstable; [
        anytype
        beeper
        bitwarden-cli
        bitwarden-desktop
        bitwarden-menu
        brave
        dbeaver-bin
        discord-canary
        pcloud
        sonixd
        spotify
        tidal-hifi
        variety
        vesktop # discord + some fixes
        vscode
        #pdfposter

        # 3D Printing
        esphome
        freecad-wayland
        orca-slicer
        prusa-slicer

        # 2nd Brain stuff
        appflowy
        obsidian # Assuming the override is handled or not needed for now
        rnote

      ]);
  }; # EOM home
}
# vim: set ts=2 sw=2 et ai list nu
