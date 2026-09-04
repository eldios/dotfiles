{
  config,
  lib,
  ...
}: let
  cfg = config.machine.suspend;
in {
  # Sleep is opt-in per host: laptops enable it, everything else refuses it
  # at the systemd level so no shell, DE or stray systemctl can suspend.
  options.machine.suspend.enable = lib.mkEnableOption "system sleep (suspend/hibernate)";

  config = lib.mkMerge [
    (lib.mkIf (!cfg.enable) {
      systemd.sleep.settings.Sleep = {
        AllowSuspend = false;
        AllowHibernation = false;
        AllowSuspendThenHibernate = false;
        AllowHybridSleep = false;
      };
      services.logind.settings.Login.IdleAction = "ignore";
    })
    (lib.mkIf cfg.enable {
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
        HandleLidSwitchDocked = "ignore";
      };
    })
  ];
}
# vim: set ts=2 sw=2 et ai list nu

