{
  config,
  pkgs,
  ...
}: let
  # Browse mako's history in the walker dmenu; the picked entry is copied
  # to the clipboard. Bound to $mod+SHIFT+N in hyprland.nix ($mod+N is the
  # lighter makoctl restore).
  notifHistory = pkgs.writeShellApplication {
    name = "notif-history";
    runtimeInputs = with pkgs; [
      jq
      libnotify
      mako
      wl-clipboard
    ];
    text = ''
      hist="$(makoctl history -j | jq -r '.[]
        | "\(.app_name // .desktop_entry // "app?"): \(.summary)\(
            if .body and .body != "" then " - " + (.body | gsub("\n"; " ")) else "" end)"')"
      if [ -z "$hist" ]; then
        notify-send -u low "Notification history" "Empty" -t 2000
        exit 0
      fi
      sel="$(printf '%s\n' "$hist" \
        | /etc/profiles/per-user/eldios/bin/walker --dmenu -p 'Notifications' || true)"
      [ -n "$sel" ] || exit 0
      printf '%s' "$sel" | wl-copy
      notify-send -u low "Copied to clipboard" -t 1500
    '';
  };
  # D-Bus activation guard: mako ships fr.emersion.mako.service, so the first
  # notification after login would start it on any stack and it would hold
  # org.freedesktop.Notifications, locking out the shells' own daemons. The
  # XDG data home copy of the service wins over the profile's, and this Exec
  # yields a mako only when the classic stack is the one recorded.
  makoDbusGuard = pkgs.writeShellScript "mako-dbus-guard" ''
    stack="$(cat "''${XDG_STATE_HOME:-$HOME/.local/state}/desktop-stack" 2>/dev/null)"
    [ "$stack" = classic ] || exit 1
    exec ${pkgs.mako}/bin/mako
  '';
in {
  home.packages = [
    pkgs.mako
    notifHistory
  ];

  services.mako.enable = false;

  xdg.dataFile."dbus-1/services/fr.emersion.mako.service".text = ''
    [D-BUS Service]
    Name=org.freedesktop.Notifications
    Exec=${makoDbusGuard}
  '';

  # Upstream omarchy pattern: only include the current theme's mako.ini, which
  # itself includes core.ini via template-generated content. Themes can opt out
  # of inheriting core (matches upstream behavior bit-for-bit).
  # max-history: mako's default keeps only 5 expired notifications; keep
  # enough for the notif-history browser to be useful.
  xdg.configFile."mako/config".text = ''
    max-history=100
    include=${config.home.homeDirectory}/.local/state/riso/current/theme/mako.ini
  '';
}
