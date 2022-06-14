{ pkgs, lib }:

let
  setupTools = with pkgs; writeScriptBin "setup" ''
    #!${runtimeShell}

    mkdir /mnt
    mount /dev/disk/by-label/nixos /mnt

    mkdir /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot

    nixos-generate-config --root /mnt
  '';

  bluetoothTools = with pkgs; writeScriptBin "btools" ''
    #!${runtimeShell}
    case $1 in
      "connected")
         ${bluez}/bin/bluetoothctl devices | \
           cut -f2 -d' ' | \
           while read uuid; do ${bluez}/bin/bluetoothctl info $uuid; done | \
           ${gawk}/bin/awk -vid=8 -vname=7 '/Connected: yes/{print r[NR%id]; print l[NR%name]};{l[NR%name]=$0; r[NR%id]=$0}'
      ;;
      *)
        echo "Bluetooth Tools Usage:"
        echo "btools command"
        echo ""
        echo "Commands:"
        echo "connected: List connected devices"
      ;;
    esac
  '';

  soundTools = with pkgs; writeScriptBin "stools" ''
    #!${runtimeShell}

    num_param () {
      re='^[0-9]+$'
      if [[ -z $1 ]]; then
        if [[ -z $2 ]]; then
          echo "Missing number parameter."
          exit 1
        elif [[ $2 =~ $re ]]; then
          echo $2
        else
          echo "Invalid parameter, expects a number: $2"
          exit 1
        fi
      elif [[ $1 =~ $re ]]; then
        echo $1
      else
        echo "Invalid parameter, expects a number: $1"
        exit 1
      fi
    }
    case $1 in
      "vol")
        case $2 in
          "get")
            sink=$(${pulseaudio}/bin/pactl info | ${gawk}/bin/awk -F': ' '/Default Sink/{print $2}')
            ${pulseaudio}/bin/pactl list sinks | ${gawk}/bin/awk "\$1 ~ /Volume/ && \$5 ~ /[0-9]+/{if(found_sink){ print \$5; found_sink=0}}; /Name: $sink/{found_sink=1}"
          ;;

          "up")
            sink=$(${pulseaudio}/bin/pactl info | ${gawk}/bin/awk -F': ' '/Default Sink/{print $2}')
            curr_vol=$(${pulseaudio}/bin/pactl list sinks | ${gawk}/bin/awk "\$1 ~ /Volume/ && \$5 ~ /[0-9]+/{if(found_sink){ print (\$5+0); found_sink=0}}; /Name: $sink/{found_sink=1}")
            delta=$(num_param $3 2)
            if [ $? = 1 ]; then
              echo $delta
              exit 1
            fi
            max_vol=$(num_param $4 150)
            if [ $? = 1 ]; then
              echo $max_vol
              exit 1
            fi
            new_vol=$((curr_vol+delta))
            ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ $((new_vol>max_vol ? max_vol : new_vol))%
          ;;
          "down")
            sink=$(${pulseaudio}/bin/pactl info | ${gawk}/bin/awk -F': ' '/Default Sink/{print $2}')
            curr_vol=$(${pulseaudio}/bin/pactl list sinks | ${gawk}/bin/awk "\$1 ~ /Volume/ && \$5 ~ /[0-9]+/{if(found_sink){ print (\$5+0); found_sink=0}}; /Name: $sink/{found_sink=1}")
            delta=$(num_param $3 2)
            if [ $? = 1 ]; then
              echo $vol
              exit 1
            fi
            new_vol=$((curr_vol-delta))
            ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ $((new_vol<0 ? 0 : new_vol))%
          ;;
          "set")
            vol=$(num_param $3)
            if [ $? = 1 ]; then
              echo $vol
              exit 1
            fi
            ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ ''${vol}%
          ;;
          "toggle")
            ${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
          ;;
          *)
            echo "Usage"
            echo "stools vol command"
            echo ""
            echo "Commands:"
            echo "get: Get current default sink volume"
            echo "up: Raise the % default sink volume. \$1=2 is vol delta, \$2=150 is max vol"
            echo "down: Lower the % default sink volume. \$1=2 is vol delta"
            echo "set \$1: Set the % default sink volume to \$1."
            echo "toggle: Mute/unmute default sink volume"
          ;;
        esac
      ;;
      "mic")
        case $2 in
          "toggle")
            ${pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle
          ;;
          *)
            echo "Usage"
            echo "stools mic command"
            echo ""
            echo "Commands:"
            echo "toggle: Mute/unmute default source mic"
          ;;
        esac
      ;;
      *)
        echo "Sound Tools Usage"
        echo "stools command"
        echo ""
        echo "Commands:"
        echo "vol: actions related to volume"
      ;;
    esac
  '';
in
{
  overlay = (final: prev: {
    scripts.setupTools = setupTools;
    scripts.bluetoothTools = bluetoothTools;
    scripts.soundTools = soundTools;
  });
}
