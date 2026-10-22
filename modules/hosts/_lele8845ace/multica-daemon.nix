{
  config,
  pkgs,
  ...
}: let
  home = config.home.homeDirectory;
  user = config.home.username;
in {
  # The Multica runtime daemon for the agents. Its environment is the agents'
  # only: Claude Code auto-memory is off for agent runs (their memory lives in
  # Hindsight) and stays on in interactive sessions.
  sops.templates."agents/hindsight.systemd.env" = {
    content = "HINDSIGHT_TOKEN=${config.sops.placeholder."tokens/mcp/hindsight_token"}\n";
    path = "${home}/.config/agents/hindsight.systemd.env";
    mode = "0600";
  };

  # The unit name is the one `multica daemon autostart` uses: the daemon
  # recognises it and hands a binary update over with exit status 42.
  systemd.user.services.multica-daemon = {
    Unit = {
      Description = "Multica agent runtime daemon";
      After = ["sops-nix.service"];
      Wants = ["sops-nix.service"];
      StartLimitIntervalSec = 120;
      StartLimitBurst = 5;
      # A rebuild must not cut off running agent tasks: restart by hand
      # when the daemon is idle.
      X-SwitchMethod = "keep-old";
    };
    Service = {
      ExecStart = "${pkgs.multica}/bin/multica daemon start --foreground";
      Environment = [
        "CLAUDE_CODE_DISABLE_AUTO_MEMORY=1"
        "PATH=/run/wrappers/bin:${home}/.nix-profile/bin:/nix/profile/bin:${home}/.local/state/nix/profile/bin:/etc/profiles/per-user/${user}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
      ];
      EnvironmentFile = config.sops.templates."agents/hindsight.systemd.env".path;
      Restart = "on-failure";
      RestartSec = 10;
      RestartForceExitStatus = 42;
    };
    Install.WantedBy = ["default.target"];
  };
}
# vim: set ts=2 sw=2 et ai list nu

