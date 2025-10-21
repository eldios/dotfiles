{ ... }:
{
  # User-level WirePlumber and PipeWire configuration
  # Complements the system-level audio configuration

  xdg.configFile."wireplumber/wireplumber.conf.d/50-alsa-config.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          {
            node.name= "alsa_output.usb-Schiit_Audio_Schiit_Unison_Modius_ES-00.iec958-stereo"
          },
          {
            node.name= "alsa_output.usb-Schiit_Audio_Schiit_Bifrost_2_Unison_USB-00.iec958-stereo"
          }
        ]
        actions = {
          update-props = {
            priority.session = 10000,
            audio.rate = 192000
          }
        }
      },
      {
        matches = [
          {
            node.name= "~alsa_output.usb-HiBy_HiBy_R4.*"
          }
        ]
        actions = {
          update-props = {
            priority.session = 9000,
            audio.rate = 192000,
            audio.allowed-rates = [ 32000, 44100, 48000, 88200, 96000, 176400, 192000, 352800, 384000, 705600, 768000 ],
            api.alsa.period-size = 256,
            api.alsa.headroom = 1024
          }
        }
      }
    ]
  '';

  xdg.configFile."pipewire/pipewire.conf.d/audio-optimization.conf".text = ''
    {
      "context.properties": {
        "default.clock.allowed-rates": [
          32000,
          44100,
          48000,
          88200,
          96000,
          176400,
          192000,
          352800,
          384000,
          705600,
          768000
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
