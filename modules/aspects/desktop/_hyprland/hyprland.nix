{
  lib,
  pkgs,
  ...
}: let
  # Open the clipboard picker of whichever shell is running, wait for the
  # user to pick an entry (the picker copies it on select), then save the
  # resulting clipboard to a file chosen through a GTK save dialog; the
  # extension follows the detected mime type.
  # Selection is detected via `wl-paste --watch`, which fires on every
  # selection event even when the content is unchanged; its first event
  # always describes the current selection, so the pick is event #2.
  clipSave = pkgs.writeShellApplication {
    name = "clip-save";
    runtimeInputs = with pkgs; [
      coreutils
      file
      gnugrep
      libnotify
      wl-clipboard
      zenity
    ];
    text = ''
      tmp=""
      fifo="$(mktemp -u -t clip-save.XXXXXX)"
      mkfifo "$fifo"
      wl-paste --watch echo picked > "$fifo" &
      watchpid=$!
      trap 'kill "$watchpid" 2>/dev/null; rm -f "$fifo" "$tmp"' EXIT

      /etc/profiles/per-user/eldios/bin/shell-dispatch clipboard

      picks=0
      while [ "$picks" -lt 2 ]; do
        if ! read -r -t 120 _; then
          exit 0
        fi
        picks=$((picks + 1))
      done < "$fifo"

      tmp="$(mktemp -t clip-save.XXXXXX)"

      # Prefer an offered image type; otherwise take the default (text).
      imgtype="$(wl-paste --list-types | grep -m1 '^image/' || true)"
      if [ -n "$imgtype" ]; then
        wl-paste --type "$imgtype" > "$tmp"
      else
        wl-paste --no-newline > "$tmp"
      fi

      mime="$(file --brief --mime-type "$tmp")"
      case "$mime" in
        image/jpeg) ext="jpg" ;;
        image/svg+xml) ext="svg" ;;
        image/*) ext="''${mime#image/}" ;;
        application/json) ext="json" ;;
        application/pdf) ext="pdf" ;;
        text/*) ext="txt" ;;
        *) ext="bin" ;;
      esac

      default="$HOME/Pictures/Screenshots/clip_$(date +%F_%H%M%S).$ext"
      # Save-mode dialog = directory navigation + filename in one step,
      # prefilled with the default; GTK itself confirms on overwrite.
      dest="$(zenity --file-selection --save --title 'Save clipboard as...' --filename "$default")" || exit 0
      [ -n "$dest" ] || dest="$default"

      mkdir -p "$(dirname "$dest")"
      mv "$tmp" "$dest"
      notify-send "Clipboard saved" "$dest"
    '';
  };
in {
  home = {
    packages = with pkgs; [
      adwaita-icon-theme
      adwaita-qt
      adwaita-qt6
      bemenu
      catppuccin-gtk
      catppuccin-kvantum
      cliphist
      clipSave
      dconf
      dracula-theme
      fuseiso
      gammastep
      geoclue2
      glpaper
      gnome-themes-extra
      grim
      grimblast
      gsettings-desktop-schemas
      hyprland-protocols
      hyprpaper
      hyprpicker
      hyprshot
      kitty
      lavalauncher
      libva-utils
      mako
      papirus-icon-theme
      pinentry-bemenu
      polkit_gnome
      qt5.qtwayland
      qt6.qmake
      qt6.qtwayland
      shotman
      slurp
      swaybg
      swayr
      swayrbar
      tofi
      udiskie
      wayland
      wbg
      wdisplays
      wev
      wl-clipboard
      wl-clip-persist
      wl-gammactl
      wl-screenrec
      wlogout
      wlr-layout-ui
      wlr-randr
      wlroots
      wlsunset
      wshowkeys
      wtype
      xdg-utils
      ydotool
    ];
  };

  # NixOS owns the portals (gtk+hyprland+wlr from desktop-gui.nix); an
  # HM-side xdg.portal would shadow that set with an incomplete one and GTK
  # apps would lose org.freedesktop.appearance and fall back to light.
  xdg.portal.enable = lib.mkForce false;

  # The session config is Lua: the entrypoint comes from omarchy-shell.nix,
  # which resolves the helper layer's store path, and these are the modules it
  # loads. hyprland.conf below carries nothing but the monitor layout.
  xdg.configFile."hypr/lua/settings.lua".source = ./hypr/settings.lua;
  xdg.configFile."hypr/lua/bindings.lua".source = ./hypr/bindings.lua;
  xdg.configFile."hypr/lua/windows.lua".source = ./hypr/windows.lua;
  xdg.configFile."hypr/lua/autostart.lua".source = ./hypr/autostart.lua;
  xdg.configFile."hypr/lua/hyprlang_compat.lua".source = ./hypr/hyprlang-compat.lua;

  # xdg-desktop-portal-hyprland: tick "allow restore token" by default so the
  # share picker remembers the selection. Screen-share apps (Chromium/Electron)
  # can then restore it instead of re-prompting, which is what made Discord/
  # Vivaldi require selecting the same window twice.
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      allow_token_by_default = true
    }
  '';

  # The home-manager hyprland module is deliberately not used: the session
  # and its package come from NixOS (nixos.nix next to this file), the
  # config is the Lua tree above, and monitors are declared through
  # desktop.hyprland.monitors. Nothing here speaks hyprlang.
}
# EOF

