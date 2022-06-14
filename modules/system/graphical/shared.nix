{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.graphical;
  systemCfg = config.machineData.systemConfig;

  isGnome = systemCfg.graphical.wayland.desktop-environment == "gnome";
in
{
  config = {
    xdg.portal = {
      enable = true;
      gtkUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    environment.etc = {
      "profile.local".text = builtins.concatStringsSep "\n" ([
        ''
          # /etc/profile.local: DO NOT EDIT -- this file has been generated automatically.
          if [ -f "$HOME/.profile" ]; then
          . "$HOME/.profile"
          fi
        ''
      ] ++ (if cfg.xorg.enable then [
        ''
          if [ -z "$DISPLAY" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec startx
          fi
        ''
      ] else [ ]) ++ (if cfg.wayland.enable && !isGnome then [
        ''
          if [ -z "$DISPLAY" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec $HOME/.winitrc
          fi
        ''
      ] else [ ]));
    };
  };
}
