{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Audio subsystem configuration for high-quality audio playback
  # Optimized for audiophile-grade DACs and high-resolution audio

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true; # For PulseAudio applications
    alsa = {
      enable = true;
      support32Bit = true; # Good for compatibility
    };
    jack.enable = false; # PipeWire provides JACK library compatibility by default
    # so dedicated JACK server is not needed for most cases.
    wireplumber.enable = true; # Recommended session manager

    # PipeWire configuration for high-quality audio
    # Supports ultra-high sample rates up to 768kHz for premium DACs
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.allowed-rates" = [
          32000
          44100
          48000
          88200
          96000
          176400
          192000
          352800
          384000
          705600
          768000
        ];
        "default.clock.rate" = 48000; # More compatible default
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 8192;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [
            "ifexists"
            "nofail"
          ];
        }
      ];
      "stream.properties" = {
        "node.latency" = "256/48000";
        "resample.quality" = 10;
        "resample.disable" = false;
      };
    };

    # WirePlumber configuration to make sinks follow the source sample rate
    # This allows automatic sample rate switching based on content
    extraConfig.pipewire."51-alsa-disable-suspension" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              # Match Schiit Bifrost 2 (up to 192kHz)
              "node.name" = "~alsa_output.usb-Schiit_Audio_Schiit_Bifrost_2_Unison_USB*";
            }
          ];
          actions = {
            update-props = {
              # Prevent the device from suspending
              "session.suspend-timeout-seconds" = 0;
              # Allow the device to follow the graph sample rate
              "audio.rate" = 0; # 0 means "follow the graph rate"
              "audio.allowed-rates" = [
                44100
                48000
                88200
                96000
                176400
                192000
              ];
              # Increase priority so this device becomes the default
              "priority.session" = 2000;
              "priority.driver" = 2000;
            };
          };
        }
        {
          matches = [
            {
              # Match HiBy R4 - supports up to 768kHz!
              "node.name" = "~alsa_output.usb-HiBy_HiBy_R4*";
            }
          ];
          actions = {
            update-props = {
              # Prevent the device from suspending
              "session.suspend-timeout-seconds" = 0;
              # Allow the device to follow the graph sample rate
              "audio.rate" = 0; # 0 means "follow the graph rate"
              "audio.allowed-rates" = [
                32000
                44100
                48000
                88200
                96000
                176400
                192000
                352800
                384000
                705600
                768000
              ];
              # High priority but lower than Bifrost (for A-B comparison)
              "priority.session" = 1900;
              "priority.driver" = 1900;
            };
          };
        }
        {
          matches = [
            {
              # Match Schiit Modius (if present)
              "node.name" = "~alsa_output.usb-Schiit_Audio_Schiit_Unison_Modius*";
            }
          ];
          actions = {
            update-props = {
              "session.suspend-timeout-seconds" = 0;
              "audio.rate" = 0;
              "audio.allowed-rates" = [
                44100
                48000
                88200
                96000
                176400
                192000
              ];
              "priority.session" = 1800;
              "priority.driver" = 1800;
            };
          };
        }
      ];
    };
  };
}

# vim: set ts=2 sw=2 et ai list nu
