# Portable-machine power handling: thermald and auto-cpufreq (powersave on
# battery, performance on the charger), powertop tuning, fingerprint login,
# and a power button that never shuts the machine down. Sleep itself stays
# opt-in per host through machine.suspend.
{
  den.aspects.laptop.nixos = {
    systemd.services.fprintd = {
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "simple";
    };

    services = {
      fprintd.enable = true;

      # don't shutdown when power button is short-pressed
      logind.settings.Login.HandlePowerKey = "ignore";

      thermald.enable = true;
      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            governor = "powersave";
            turbo = "never";
          };
          charger = {
            governor = "performance";
            turbo = "auto";
          };
        };
      };
    };

    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
    };
  };
}
