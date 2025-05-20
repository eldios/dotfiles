{ ... }:
{
  services = {
    syncthing.tray.enable = true;
  };

  xdg.configFile."wireplumber/wireplumber.conf.d/50-alsa-config.conf".text = ''
      monitor.alsa.rules = [
      {
        matches = [
          {
            node.name= "alsa_output.usb-Schiit_Audio_Schiit_Unison_Modius_ES-00.iec958-stereo"
          }
        ]
        actions = {
          update-props = {
            priority.session = 10000,
            audio.rate = 192000
          }
        }
      }
    ]
  '';

  xdg.configFile."pipewire/pipewire.conf.d/audio-optimization.conf".text = ''
    {
      "context.properties": {
        "default.clock.allowed-rates": [
          44100,
          48000,
          88200,
          96000,
          176400,
          192000
        ],
        "default.clock.rate": 192000,
        "resample.quality": 10,
        "vm.overrides": {
          "default.clock.min-quantum": 2048
        }
      }
    }
  '';
} # EOF
# vim: set ts=2 sw=2 et ai list nu
