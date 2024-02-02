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
      "bitwarden"
      "cryptomator"
      "dbeaver-community"
      "discord"
      "displaylink"
      "elgato-stream-deck"
      "firefox"
      "gimp"
      "hammerspoon"
      "iina"
      "inkscape"
      "istat-menus"
      "keybase"
      "obs"
      "obs-virtualcam"
      "obsbot-center"
      "obsidian" # notetaking 2nd brain
      "orbstack" # https://github.com/OrbStack/orbstack - docker on steroid
      "pock" # macOS dock app (made by an italian)
      "qmk-toolbox"
      "rectangle" # tiling window manager for Mac
      "smplayer"
      "spotify"
      "syncthing"
      "tailscale"
      "telegram-desktop"
      "utm" # QEMU GUI
      "vivaldi" # QEMU GUI
      "vlc"
      "vlc-webplugin"
      "warp" # https://warp.dev - fancy terminal
      "zoom"
    ];
  };
}

# vim: set ts=2 sw=2 et ai list nu
