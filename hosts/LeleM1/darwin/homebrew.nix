{ pkgs, ... }:
{
  homebrew = {
    enable = true;

    global.autoUpdate = true;
    onActivation = {
      upgrade = true;
      cleanup = "uninstall";
      extraFlags = [
        "--force"
      ];
    };

    # Taps
    taps = [
      "osx-cross/avr"
      "osx-cross/arm"
    ];

    # Apps from the Apple Store
    #masApps = [];

    # Brews
    brews = [
      "colima" # based on lima - Docker in Lima VM
      "lima" # QEMU GUI tool
      "teensy_loader_cli" # needed for some ESP32 or ESP8266
    ];

    # Casks
    casks = [
      "alfred"
      "amethyst"
      "autodesk-fusion360"
      "balenaetcher"
      "bartender"
      "beeper"
      "bitwarden"
      "brave-browser"
      "canva"
      "cryptomator"
      "dbeaver-community"
      "discord"
      "displaylink"
      "element"
      "elgato-stream-deck"
      "firefox"
      "gimp"
      "hammerspoon"
      "iina"
      "inkscape"
      "istat-menus"
      "keybase"
      "mailspring"
      "obs"
      "obs-virtualcam"
      "obsbot-center"
      "obsidian" # notetaking 2nd brain
      "orbstack" # https://github.com/OrbStack/orbstack - docker on steroid
      "pock" # macOS dock app (made by an italian)
      "qflipper"
      "qmk-toolbox"
      "rectangle" # tiling window manager for Mac
      "signal"
      "slack"
      "smplayer"
      "spotify"
      "syncthing"
      "tailscale"
      "telegram-desktop"
      "utm" # QEMU GUI
      "vivaldi" # browser
      "vlc"
      "vlc-webplugin"
      "warp" # https://warp.dev - fancy terminal
      "whatsapp"
      "zoom"
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
