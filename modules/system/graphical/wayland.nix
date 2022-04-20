{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.graphical.wayland;
in
{
  options.zoedsoupe.graphical.wayland = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = false;
    };

    swaylock-pam = mkOption {
      description = "Enable swaylock pam";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-gtk
        ];
        gtkUsePortal = true;
      };
    };

    security.pam.services.swaylock = mkIf (cfg.swaylock-pam) {};
  };
}
