{ pkgs, lib, ... }:

let
  # Manage Variety's set_wallpaper script with swww support
  # This fixes the grey background issue when using swww-daemon (MangoWC, Hyprland, etc.)
  # Variety's default script only supports swaybg, not swww.
  #
  # NOTE: We use an activation script to COPY (not symlink) into ~/.config/variety/scripts/
  # because Variety's prepare_config_folder() calls os.chmod() on its scripts at startup,
  # which fails on read-only Nix store symlinks.
  setWallpaperScript = pkgs.writeShellScript "set_wallpaper" ''
      #!/bin/bash
      # Variety set_wallpaper script - managed by home-manager
      # Added swww support for MangoWC/Hyprland/wlroots compositors
      #
      # PARAMETERS:
      # $1: Absolute path to the wallpaper image (after effects)
      # $2: "auto" | "manual" | "refresh"
      # $3: Absolute path to the original wallpaper image
      # $4: Display mode: "os", "zoom", "centered", "scaled", "stretched", "spanned", "wallpaper"

      WP=$1

      # Enlightenment / Moksha
      if [[ "$DESKTOP" == *"Enlightenment"* ]] || [[ "$DESKTOP" == *"Moksha"* ]]; then
        OUTPUT_DIR="$HOME/.e/e/backgrounds"
        TEMPLATE='
        images { image: "@IMAGE@" USER; }
        collections {
          group {
          name: "e/desktop/background";
          data { item: "style" "4"; item: "noanimation" "1"; }
          max: @WIDTH@ @HEIGHT@;
          parts {
            part {
            name: "bg";
            mouse_events: 0;
            description {
              state: "default" 0.0;
              aspect: @ASPECT@ @ASPECT@;
              aspect_preference: NONE;
              image { normal: "@IMAGE@"; scale_hint: STATIC; }
            }
            }
          }
          }
        }
        '
        OFILE="$OUTPUT_DIR/variety_wallpaper_$RANDOM"
        DIMENSION="$(identify -format "%w/%h" "$WP")"
        if [ ! -z "$DIMENSION" ]; then
          WIDTH="$(echo "$DIMENSION" | cut -d/ -f1)"
          HEIGHT="$(echo "$DIMENSION" | cut -d/ -f2)"
          IMAGE="$(echo "$WP" | sed 's/[^[:alnum:]_-]/\\&/g')"
          if [ -z "$HEIGHT" ] || [ "$HEIGHT" = "0" ]; then
            ASPECT="0.0"
          else
            ASPECT="$(echo "scale=9; $DIMENSION" | bc)"
          fi
        fi
        printf "%s" "$TEMPLATE" |
          sed "s/@ASPECT@/$ASPECT/g; s/@WIDTH@/$WIDTH/g; s/@HEIGHT@/$HEIGHT/g; s|@IMAGE@|$IMAGE|g" >"$OFILE.edc"
        edje_cc "$OFILE.edc" "$OFILE.edj" 2>/dev/null
        rm "$OFILE.edc"
        desk_x_count=$(enlightenment_remote -desktops-get | awk '{print $1}')
        desk_y_count=$(enlightenment_remote -desktops-get | awk '{print $2}')
        screen_count=1
        if command -v xrandr >/dev/null 2>&1; then
          screen_count=$(xrandr -q | grep -c ' connected')
        fi
        for ((x = 0; x < desk_x_count; x++)); do
          for ((y = 0; y < desk_y_count; y++)); do
            for ((z = 0; z < screen_count; z++)); do
              enlightenment_remote -desktop-bg-add 0 "$z" "$x" "$y" "$OFILE.edj" &
            done
          done
        done
        LAST_WALLPAPER_FILE="$HOME/.config/variety/.enlightenment_last_wallpaper.txt"
        if [ -e "$LAST_WALLPAPER_FILE" ]; then
          find "$OUTPUT_DIR" -name "variety_wallpaper*.*" | grep -v "$OFILE.edj" | grep -v "$(cat "$LAST_WALLPAPER_FILE")" | xargs rm
        else
          find "$OUTPUT_DIR" -name "variety_wallpaper*.*" | grep -v "$OFILE.edj" | xargs rm
        fi
        echo "$OFILE.edj" >"$LAST_WALLPAPER_FILE"
      fi

      # KDE Plasma
      if [ "''${KDE_FULL_SESSION}" == "true" ]; then
        plasma_qdbus_script="
          let allDesktops = desktops();
          for (let d of allDesktops) {
            if (d.wallpaperPlugin == 'org.kde.image') {
              d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
              d.writeConfig('Image', 'file://""$WP""');
            }
          }
        "
        if [[ -n "''${KDE_SESSION_VERSION}" && "''${KDE_SESSION_VERSION}" -ge '5' ]]; then
          dbus-send --type=method_call --dest=org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript string:"$plasma_qdbus_script"
          dbus_exitcode="$?"
          if [[ "$dbus_exitcode" -ne 0 && "''${KDE_SESSION_VERSION}" -eq '5' ]]; then
            kdialog --title "Variety: cannot change Plasma wallpaper" --passivepopup "Could not change the Plasma 5 wallpaper" --icon variety 10
          fi
          exit "$dbus_exitcode"
        else
          WALLDIR="$(xdg-user-dir PICTURES)/variety-wallpaper"
          mkdir -p "$WALLDIR"
          rm -fv "''${WALLDIR}"/*
          NEWWP="''${WALLDIR}/wallpaper-kde-$RANDOM.jpg"
          cp "$WP" "$NEWWP"
          touch "$NEWWP"
        fi
      fi

      # GNOME 3 / Unity
      gsettings set org.gnome.desktop.background picture-uri "file://$WP" 2>/dev/null
      gsettings set org.gnome.desktop.background picture-uri-dark "file://$WP" 2>/dev/null
      if [[ "$4" =~ ^(wallpaper|centered|scaled|stretched|zoom|spanned)$ ]]; then
        gsettings set org.gnome.desktop.background picture-options "$4"
      fi
      if [ "$(gsettings get org.gnome.desktop.background picture-options)" == "'none'" ]; then
        gsettings set org.gnome.desktop.background picture-options 'zoom'
      fi

      # GNOME Screensaver / Lock screen
      gsettings set org.gnome.desktop.screensaver picture-uri "file://$WP" 2>/dev/null
      if [[ "$4" =~ ^(wallpaper|centered|scaled|stretched|zoom|spanned)$ ]]; then
        gsettings set org.gnome.desktop.screensaver picture-options "$4"
      fi
      if [ "$(gsettings get org.gnome.desktop.screensaver picture-options)" == "'none'" ]; then
        gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
      fi

      # Deepin
      if [ "$(gsettings list-schemas | grep -c com.deepin.wrap.gnome.desktop.background)" -ge 1 ]; then
        gsettings set com.deepin.wrap.gnome.desktop.background picture-uri "file://$WP"
        if [[ "$4" =~ ^(wallpaper|centered|scaled|stretched|zoom|spanned)$ ]]; then
          gsettings set com.deepin.wrap.gnome.desktop.background picture-options "$4"
        fi
        if [ "$(gsettings get com.deepin.wrap.gnome.desktop.background picture-options)" == "'none'" ]; then
          gsettings set com.deepin.wrap.gnome.desktop.background picture-options 'zoom'
        fi
      fi

      # XFCE
      command -v xfconf-query >/dev/null 2>&1
      rc=$?
      if [[ $rc = 0 ]]; then
        for i in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep -E -e "screen.*/monitor.*image-path$" -e "screen.*/monitor.*/last-image$"); do
          xfconf-query -c xfce4-desktop -p "$i" -n -t string -s "" 2>/dev/null
          xfconf-query -c xfce4-desktop -p "$i" -s "" 2>/dev/null
          xfconf-query -c xfce4-desktop -p "$i" -s "$WP" 2>/dev/null
        done
      fi

      # LXDE
      if [ "$XDG_CURRENT_DESKTOP" == "LXDE" ]; then
        pcmanfm --set-wallpaper "$WP" 2>/dev/null
      fi

      # LXQt
      if [ "$XDG_CURRENT_DESKTOP" == "LXQt" ]; then
        pcmanfm-qt --set-wallpaper "$WP" 2>/dev/null
      fi

      # Simple WMs (X11) - feh or nitrogen
      SIMPLE_WMS=("bspwm" "dwm" "herbstluftwm" "none+i3" "i3" "i3-gnome" "i3-with-shmlog" "jwm" "LeftWM" "openbox" "qtile" "qtile-venv" "spectrwm" "xmonad")
      if [[ " ''${SIMPLE_WMS[*]} " = *" $XDG_CURRENT_DESKTOP "* || " ''${SIMPLE_WMS[*]} " = *" $XDG_SESSION_DESKTOP "* ||
        " ''${SIMPLE_WMS[*]} " = *" $DESKTOP_SESSION "* ]]; then
        if command -v "feh" >/dev/null 2>&1; then
          feh --bg-fill "$WP" 2>/dev/null
        elif command -v "nitrogen" >/dev/null 2>&1; then
          nitrogen --set-zoom-fill --save "$WP" 2>/dev/null
        fi
      fi

      # =====================================================================
      # swww support (for MangoWC, Hyprland, and other wlroots compositors)
      # Must come BEFORE swaybg fallback since both may be installed
      # =====================================================================
      if command -v ${pkgs.swww}/bin/swww >/dev/null 2>&1 && ${pkgs.swww}/bin/swww query >/dev/null 2>&1; then
        ${pkgs.swww}/bin/swww img "$WP" \
          --transition-type fade \
          --transition-duration 1 \
          --transition-fps 60
      else
        # swaybg fallback (Sway, SwayFX, etc.)
        PID=$(pidof swaybg)
        if [[ -n $PID ]]; then
          if command -v "swaybg" >/dev/null 2>&1; then
            swaybg -i "$WP" -m fill &
            if [ ! -z "$PID" ]; then
              sleep 1
              kill $PID 2>/dev/null
            fi
          else
            swaymsg output "*" bg "$WP" fill 2>/dev/null
          fi
        fi
      fi

      # Trinity
      if [ "$XDG_CURRENT_DESKTOP" == "Trinity" ]; then
        dcop kdesktop KBackgroundIface setWallpaper "$WP" 4 2>/dev/null
      fi

      # MATE
      gsettings set org.mate.background picture-filename "$WP" 2>/dev/null
      if [ "$(gsettings get org.mate.desktop.background picture-options 2>/dev/null)" == "'none'" ]; then
        gsettings set org.mate.desktop.background picture-options 'zoom'
      fi
      if [[ "$4" =~ ^(wallpaper|centered|scaled|stretched|zoom|spanned)$ ]]; then
        gsettings set org.mate.desktop.background picture-options "$4"
      fi

      # Cinnamon
      gsettings set org.cinnamon.desktop.background picture-uri "file://$WP" 2>/dev/null
      if [ "$(gsettings get org.cinnamon.desktop.background picture-options 2>/dev/null)" == "'none'" ]; then
        gsettings set org.cinnamon.desktop.background picture-options 'zoom'
      fi
      if [[ "$4" =~ ^(wallpaper|centered|scaled|stretched|zoom|spanned)$ ]]; then
        gsettings set org.cinnamon.desktop.background picture-options "$4"
      fi

      # Awesome WM
      if [[ "$XDG_SESSION_DESKTOP $DESKTOP_STARTUP_ID $DESKTOP_SESSION $XDG_CURRENT_DESKTOP" == *"awesome"* ]]; then
        echo "for s in screen do require(\"gears\").wallpaper.maximized(\"$1\", s) end" | awesome-client
      fi

      exit 0
  '';
in {
  home.activation.varietyScripts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/variety/scripts"
    install -m 0755 ${setWallpaperScript} "$HOME/.config/variety/scripts/set_wallpaper"
  '';
}
# vim: set ts=2 sw=2 et ai list nu
