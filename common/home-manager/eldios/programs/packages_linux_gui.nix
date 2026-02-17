# Packages for Linux-specific graphical user interface tools.
# This includes applications, theming, and services like gpg-agent.
# NOTE: kitty is installed via programs.kitty.enable in kitty.nix
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
        # System & Desktop Utils
        appimage-run # run AppImage applications on NixOS
        arandr # visual X11 display arranger
        gcal # GNU calendar
        geoclue2 # geolocation service
        gromit-mpx # screen annotation tool
        mission-center # system monitor GUI (like Task Manager)
        paperview # live wallpaper from images
        playerctl # media player controller (MPRIS)
        redshift # screen color temperature adjuster
        resources # system resource monitor GUI
        unclutter # auto-hide mouse cursor when idle
        xclip # X11 clipboard tool
        xdotool # X11 window automation tool

        # Audio
        audacity # audio editor and recorder
        cava # audio visualizer in terminal
        cavalier # GUI audio visualizer
        easyeffects # audio effects processor for PipeWire
        pavucontrol # PulseAudio/PipeWire volume control
        pulseaudio # audio tools (pactl, etc.)

        # Web Browsers
        vivaldi # Chromium-based web browser
        vivaldi-ffmpeg-codecs # codec support for Vivaldi
        widevine-cdm # DRM content decryption module

        # Communication
        signal-desktop # encrypted messaging app
        slack # team communication platform
        telegram-desktop # messaging app
        zoom-us # video conferencing

        # Media Players
        mpv # lightweight media player
        vlc # versatile multimedia player

        # Streaming & Recording
        obs-studio # streaming and recording software
        screenkey # show key presses on screen
        streamcontroller # Stream Deck controller software

        # Graphics & Design
        dia # diagram editor
        gimp-with-plugins # image editor
        graph-easy # ASCII/Unicode graph renderer
        graphviz # graph visualization (dot, neato)
        inkscape # vector graphics editor
        scribus # desktop publishing

        # Disk & Partitioning
        gparted # partition editor GUI

        # File Management
        filezilla # FTP/SFTP file transfer client
        pcmanfm # lightweight file manager

        # Remote Access
        freerdp # Remote Desktop Protocol client
        input-leap # KVM software for multiple computers
        remmina # remote desktop client (RDP, VNC, SSH)
        spice # virtual display protocol tools

        # Backup & Sync
        cryptomator # encrypted cloud storage vault
        pika-backup # simple backup tool (Borg frontend)
        syncthing # peer-to-peer file synchronization
        vorta # Borg Backup GUI frontend

        # Dev Tools
        cool-retro-term # retro-styled terminal emulator
        dive # Docker image layer explorer
        lens # Kubernetes IDE
        zed-editor # high-performance code editor

        # Camera & Webcam
        cameractrls # camera settings controller GUI
        guvcview # webcam viewer and capture tool
        uvcdynctrl # UVC camera dynamic control

        # Document Viewers
        zathura # minimal PDF/document viewer

        # Handwriting & Notes
        krita # digital painting application
        saber # handwritten notes app
        styluslabs-write-bin # handwriting note-taking app
        xournalpp # handwritten notes and PDF annotation

        # Virtualization
        quickgui # QuickEmu GUI frontend for VMs

        # Games
        uqm # The Ur-Quan Masters (Star Control II)
      ])
      ++ (with pkgs.unstable; [
        # Web Browsers
        brave # privacy-focused web browser

        # Communication
        beeper # unified messaging (all chats in one app)
        discord-canary # chat platform (canary build)
        vesktop # Discord client with Vencord fixes
        wasistlos # WhatsApp desktop client

        # Password Management
        bitwarden-cli # password manager CLI
        bitwarden-desktop # password manager GUI
        bitwarden-menu # password manager dmenu/rofi integration

        # Media & Music
        sonixd # Subsonic/Jellyfin music client
        spotify # music streaming service
        tidal-hifi # TIDAL music streaming client

        # Cloud Storage
        pcloud # pCloud storage client

        # Dev Tools
        dbeaver-bin # database management GUI
        vscode # Visual Studio Code editor

        # Desktop Customization
        anytype # knowledge management and wiki tool
        variety # automatic wallpaper changer

        # 3D Printing & IoT
        esphome # ESP microcontroller firmware manager
        freecad-wayland # parametric 3D CAD modeler
        orca-slicer # 3D printer slicer
        prusa-slicer # 3D printer slicer (Prusa)

        # 2nd Brain & Notes
        appflowy # open-source Notion alternative
        obsidian # knowledge base and note-taking
        rnote # vector drawing and handwriting app
      ]);
  }; # EOM home
}
# vim: set ts=2 sw=2 et ai list nu
