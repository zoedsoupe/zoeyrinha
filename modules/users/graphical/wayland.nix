{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.graphical.wayland;
  systemCfg = config.machineData.systemConfig;

  swayStartup = pkgs.writeShellScriptBin "sway-setup" ''
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
      eval $(dbus-launch --exit-with-session --sh-syntax)
    fi

    ## https://bbs.archlinux.org/viewtopic.php?id=224652
    ## Requires --systemd becuase of gnome-keyring error. Unsure how differs from systemctl --user import-environment
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK
    fi

    systemctl --user import-environment PATH
    systemctl --user restart xdg-desktop-portal-gtk.service
    systemctl --user start sway-session.target
  '';

  swayConfig = ''
    exec ${swayStartup}/bin/sway-setup

    # Super key
    set $mod mod4

    set $left h
    set $down j
    set $up k
    set $right l

    set $term kitty
    set $menu ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu="BEMENU_SCALE=2 ${pkgs.bemenu}/bin/bemenu -i -l 8 --scrollbar autohide" --term="$term" --no-generic | xargs swaymsg exec --

    set $screenshot flameshot gui

    font pango:JetBrainsMono 10

    bindsym $mod+Return exec $term
    bindsym $mod+q kill
    bindsym $mod+p exec '$menu'
    bindsym $mod+Shift+c reload
    bindsym $mod+Shift+q exit

    bindsym $mod+f+$left focus left
    bindsym $mod+f+$down focus down
    bindsym $mod+f+$up focus up
    bindsym $mod+f+$right focus right
    bindsym $mod+Print exec $screenshot

    bindsym $mod+v splitv
    bindsym $mod+h splith

    bindsym $mod+a focus parent

    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right

    bindsym $mod+r+$left resize shrink width 5px
    bindsym $mod+r+$down resize grow height 5px
    bindsym $mod+r+$up resize shrink height 5px
    bindsym $mod+r+$right resize grow width 5px

    bindsym $mod+Shift+space fullscreen toggle
    bindsym $mod+m layout stacking
    bindsym $mod+t fullscreen disable, floating disable, layout default

    bindsym --locked XF86AudioRaiseVolume exec \
      ${pkgs.scripts.soundTools}/bin/stools vol up 5
    bindsym --locked XF86AudioLowerVolume exec \
      ${pkgs.scripts.soundTools}/bin/stools vol down 5
    bindsym --locked XF86AudioMute exec \
      ${pkgs.scripts.soundTools}/bin/stools vol toggle

    smart_borders on
    gaps inner 10

    default_border pixel 2
    output eDP-1 scale 1

    input * {
      xkb_layout us
      xkb_variant intl
      xkb_options ctrl:swapcaps
    }

    input "type:touchpad" {
      dwt enabled
      tap enabled
      natural_scroll enabled
      drag enabled
    }

    # Workspaces
    set $ws1   1:
    set $ws2   2:
    set $ws3   3:3
    set $ws4   4:4
    set $ws5   5:5
    set $ws6   6:6
    set $ws7   7:7
    set $ws8   8:8
    set $ws9   9:9
    set $ws0   10:10
    set $wsF1  11:
    set $wsF2  12:
    set $wsF3  13:13
    set $wsF4  14:14
    set $wsF5  15:15
    set $wsF6  16:16
    set $wsF7  17:17
    set $wsF8  18:
    set $wsF9  19:19
    set $wsF10 20:20
    set $wsF11 21:
    set $wsF12 22:

    bindsym $mod+1   workspace $ws1
    bindsym $mod+2   workspace $ws2
    bindsym $mod+3   workspace $ws3
    bindsym $mod+4   workspace $ws4
    bindsym $mod+5   workspace $ws5
    bindsym $mod+6   workspace $ws6
    bindsym $mod+7   workspace $ws7
    bindsym $mod+8   workspace $ws8
    bindsym $mod+9   workspace $ws9
    bindsym $mod+0   workspace $ws0
    bindsym $mod+F1  workspace $wsF1
    bindsym $mod+F2  workspace $wsF2
    bindsym $mod+F3  workspace $wsF3
    bindsym $mod+F4  workspace $wsF4
    bindsym $mod+F5  workspace $wsF5
    bindsym $mod+F6  workspace $wsF6
    bindsym $mod+F7  workspace $wsF7
    bindsym $mod+F8  workspace $wsF8
    bindsym $mod+F9  workspace $wsF9
    bindsym $mod+F10 workspace $wsF10
    bindsym $mod+F11 workspace $wsF11
    bindsym $mod+F12 workspace $wsF12

    # move focused container to workspace
    bindsym $mod+Shift+1    move container to workspace $ws1
    bindsym $mod+Shift+2    move container to workspace $ws2
    bindsym $mod+Shift+3    move container to workspace $ws3
    bindsym $mod+Shift+4    move container to workspace $ws4
    bindsym $mod+Shift+5    move container to workspace $ws5
    bindsym $mod+Shift+6    move container to workspace $ws6
    bindsym $mod+Shift+7    move container to workspace $ws7
    bindsym $mod+Shift+8    move container to workspace $ws8
    bindsym $mod+Shift+9    move container to workspace $ws9
    bindsym $mod+Shift+0    move container to workspace $ws0
    bindsym $mod+Shift+F1   move container to workspace $wsF1
    bindsym $mod+Shift+F2   move container to workspace $wsF2
    bindsym $mod+Shift+F3   move container to workspace $wsF3
    bindsym $mod+Shift+F4   move container to workspace $wsF4
    bindsym $mod+Shift+F5   move container to workspace $wsF5
    bindsym $mod+Shift+F6   move container to workspace $wsF6
    bindsym $mod+Shift+F7   move container to workspace $wsF7
    bindsym $mod+Shift+F8   move container to workspace $wsF8
    bindsym $mod+Shift+F9   move container to workspace $wsF9
    bindsym $mod+Shift+F10  move container to workspace $wsF10
    bindsym $mod+Shift+F11  move container to workspace $wsF11
    bindsym $mod+Shift+F12  move container to workspace $wsF12

    # Modes
    mode "resize" {
      bindsym Left resize shrink width 10px
      bindsym Down resize grow height 10px
      bindsym Up resize shrink height 10px
      bindsym Right resize grow width 10px

      # return to default mode
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"

    set $mode_system System: (l) lock, (e) logout, (s) suspend, (r) reboot, (S) shutdown, (R) UEFI
    mode "$mode_system" {
      bindsym l exec $lock, mode "default"
      bindsym e exit
      bindsym s exec --no-startup-id systemctl suspend, mode "default"
      bindsym r exec --no-startup-id systemctl reboot, mode "default"
      bindsym Shift+s exec --no-startup-id systemctl poweroff -i, mode "default"
      bindsym Shift+r exec --no-startup-id systemctl reboot --firmware-setup, mode "default"

      # return to default mode
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+Shift+e mode "$mode_system"
  '';
in
{
  options.zoedsoupe.graphical.wayland = {
    enable = mkOption {
      type = types.bool;
      description = "Enable wayland";
    };

    desktop-environment = mkOption {
      type = types.enum [ "gnome" "sway" ];
      description = "What desktop/wm to use";
    };

    background = {
      enable = mkOption {
        type = types.bool;
        description = "Enable background [swaybg]";
      };

      pkg = mkOption {
        type = types.package;
        description = "Package to use for swaybg";
      };

      image = mkOption {
        type = types.path;
        description = "Path to image file used for background";
      };

      mode = mkOption {
        type = types.enum [ "stretch" "fill" "fit" "center" "tile" ];
        description = "Scaling mode for background";
      };
    };

    statusbar = {
      enable = mkOption {
        type = types.bool;
        description = "Enable status bar [waybar]";
      };

      pkg = mkOption {
        type = types.package;
        description = "Waybar package";
      };
    };

    screenlock = {
      enable = mkOption {
        type = types.bool;
        description = " Enable screen locking, must enable it on system as well for pamd (swaylock)";
      };
    };
  };

  config = (mkIf cfg.enable) ({
    assertions = [{
      assertion = systemCfg.graphical.wayland.enable;
      message = "To enable xorg for user, it must be enabled for system";
    }];

    home.packages = with pkgs; [
      sway
      foot
      bemenu
      libappindicator-gtk3
      (if cfg.background.enable then swaybg else null)
      (assert systemCfg.graphical.wayland.swaylock-pam; (if cfg.screenlock.enable then swaylock else null))
    ];

    home.file = {
      ".winitrc" = {
        executable = true;
        text = ''
          # .winitrc autogenerated. Do not edit
          . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"

          # firefox enable wayland
          export MOZ_ENABLE_WAYLAND=1
          export MOZ_ENABLE_XINPUT2=1
          export XDG_CURRENT_DESKTOP=sway

          ${pkgs.sway}/bin/sway

          wait $!
          systemctl --user stop graphical-session.target
          systemctl --user stop graphical-session-pre.target

          # Wait until the units actually stop.
          while [ -n "$(systemctl --user --no-legend --state=deactivating list-units)" ];
          do
            sleep 0.5
          done
        '';
      };
    };

    xdg.configFile = {
      "foot/foot.ini" = {
        text = ''
          pad = 2x2 center
          font=JetBrainsMono Nerd Font Mono
        '';
      };
      "sway/config" = {
        text = swayConfig;
      };
    };

    systemd.user.targets = {
      sway-session = mkIf (cfg.desktop-environment == "sway") {
        Unit = {
          Description = "sway compositor session";
          Documentation = [ "man:systemd.special(7)" ];
          BindsTo = [ "wayland-session.target" ];
          After = [ "wayland-session.target" ];
        };
      };

      wayland-session = {
        Unit = {
          Description = "sway compositor session";
          BindsTo = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
      };
    };

    systemd.user.services.swaybg = mkIf cfg.background.enable {
      Unit = {
        Description = "swaybg background service";
        Documentation = [ "man:swabyg(1)" ];
        BindsTo = [ "wayland-session.target" ];
        After = [ "wayland-session.target" ];
      };

      Service = {
        ExecStart = "${cfg.background.pkg}/bin/swaybg --image ${cfg.background.image} --mode ${cfg.background.mode}";
      };

      Install = {
        WantedBy = [ "wayland-session.target" ];
      };
    };

    programs.waybar = mkIf cfg.statusbar.enable {
      enable = true;
      package = cfg.statusbar.pkg;
      settings = [
        ({
          layer = "bottom";

          modules-left = [];
          modules-center = [ "clock" ];
          modules-right = [ "cpu" "memory" "temperature" "battery" "backlight" "pulseaudio" "network" "tray" ];

          gtk-layer-shell = true;
          modules = {
            clock = {
              format = "{:%I:%M %p}";
              tooltip = true;
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };
            cpu = {
              interval = 10;
              format = "{usage}% ";
              tooltip = true;
            };
            memory = {
              interval = 30;
              format = "{used:0.1f}G/{total:0.1f}G ";
              tooltip = true;
            };
            temperature = {};
            battery = {
              bat = "BAT1";
              states = {
                good = 80;
                warning = 30;
                critical = 15;
              };
              format = "{capacity}% {icon}";
              format-charging = "{capacity}% ";
              format-plugged = "{capacity}% ";
              format-alt = "{time} {icon}";
              format-icons = [ "" "" "" "" "" ];
              tooltip = true;
              tooltip-format = "{timeTo}";
            };
            backlight = {
              device = "acpi_video1";
              format = "{percent}% {icon}";
              format-icons = [ "" "" ];
              on-scroll-up = "${pkgs.light}/bin/light -A 2";
              on-scroll-down = "${pkgs.light}/bin/light -U 1";
            };
            pulseaudio = {
              format = "{volume}% {icon} {format_source}";
              format-bluetooth = "{volume}% {icon} {format_source}";
              format-bluetooth-muted = "{volume}%  {format_source}";
              format-muted = "{volume}%  {format_source}";
              format-source = "{volume}% ";
              format-source-muted = "{volume}% ";
              format-icons = {
                "default" = [ "" "" "" ];
              };
              on-scroll-up = "${pkgs.scripts.soundTools}/bin/stools vol up 1";
              on-scroll-down = "${pkgs.scripts.soundTools}/bin/stools vol down 1";
              on-click-right = "${pkgs.scripts.soundTools}/bin/stools vol toggle";
              on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
              tooltip = true;
            };
            network = {
              interval = 60;
              interface = "wlp*";
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "{ipaddr}/{cidr} ";
              tooltip-format = "{ifname} via {gwaddr} ";
              format-linked = "{ifname} (No IP) ";
              format-disconnected = "Disconnected ⚠";
              format-alt = "{ifname}: {ipaddr}/{cidr}";
              tooltip = true;
            };
            tray = {
              spacing = 10;
            };
          };
        })
      ];
      style = ''
        * {
          font-size: 24px;
        }

        window#waybar {
          background: @theme_base_color;
          border-bottom: 1px solid @unfocused_borders;
          color: @theme_text_color;
        }
      '';
      systemd.enable = true;
    };

    systemd.user.services.waybar = mkIf cfg.statusbar.enable {
      Unit.BindsTo = lib.mkForce [ "wayland-session.target" ];
      Unit.After = lib.mkForce [ "wayland-session.target" ];
      Install.WantedBy = lib.mkForce [ "wayland-session.target" ];
    };
  });
}
