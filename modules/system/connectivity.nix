{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.connectivity;
in
{
  options.zoedsoupe.connectivity = {
    wifi.enable = mkOption {
      description = "Enable wifi with default options";
      type = types.bool;
      default = false;
    };

    bluetooth.enable = mkOption {
      description = "Enable bluetooth with default options";
      type = types.bool;
      default = false;
    };

    firewall.enable = mkOption {
      description = "Enable firewall";
      type = types.bool;
      default = false;
    };

    printing.enable = mkOption {
      description = "Enable printer";
      type = types.bool;
      default = false;
    };

    sound.enable = mkOption {
      description = "Enable sound";
      type = types.bool;
      default = false;
    };
  };

  config = {
    environment.systemPackages = with pkgs; [
    ] ++ (if (cfg.bluetooth.enable) then [
      scripts.bluetoothTools
    ] else [ ]) ++ (if (cfg.sound.enable) then [
      pulseaudio
      scripts.soundTools
    ] else [ ]) ++ (if (cfg.printing.enable) then [
      hplip
    ] else [ ]);


    networking.networkmanager.enable = cfg.wifi.enable;
    networking.firewall.enable = cfg.firewall.enable;

    services.pipewire = {
      enable = cfg.sound.enable;
      alsa.enable = cfg.sound.enable;
      alsa.support32Bit = cfg.sound.enable;
      pulse.enable = cfg.sound.enable;
      jack.enable = true;
      media-session.config.bluez-monitor.rules = [
        {
          # Matches all cards
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions = {
            "update-props" = {
              "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
              # mSBC is not expected to work on all headset + adapter combinations.
              "bluez5.msbc-support" = true;
            };
          };
        }
        {
          matches = [
            # Matches all sources
            { "node.name" = "~bluez_input.*"; }
            # Matches all outputs
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            "node.pause-on-idle" = false;
          };
        }
      ];
    };

    hardware.pulseaudio.enable = false;
    sound.enable = false;

    services.printing = {
      enable = cfg.printing.enable;
      drivers = [ pkgs.hplipWithPlugin ];
      webInterface = true;
    };

    hardware.bluetooth = {
      enable = cfg.bluetooth.enable;
      settings = {
        General = {
          Name = "zoedsoupe-note";
          DiscoverableTimeout = 0;
          AlwaysPairable = true;
          FastConnectable = true;
        };

        Policy = {
          AutoEnable = true;
          ReconnectAttempts = 5;
          ReconnectIntervals = "1,2,4,8,16";
        };
      };
    };

    services.blueman.enable = true;
  };
}
