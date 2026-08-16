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
in {
  home.packages = [
    pkgs.mako
    notifHistory
  ];

  services.mako.enable = false;

  # Upstream omarchy pattern: only include the current theme's mako.ini, which
  # itself includes core.ini via template-generated content. Themes can opt out
  # of inheriting core (matches upstream behavior bit-for-bit).
  # max-history: mako's default keeps only 5 expired notifications; keep
  # enough for the notif-history browser to be useful.
  xdg.configFile."mako/config".text = ''
    max-history=100
    include=${config.home.homeDirectory}/.config/omarchy/current/theme/mako.ini
  '';
}
