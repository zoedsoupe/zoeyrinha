{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.graphical.xorg;
in
{
  options.zoedsoupe.graphical.xorg = {
    enable = mkOption {
      description = "Enable xserver";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "ctrl:swapcaps";
      xkbVariant = "intl";
      libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          disableWhileTyping = true;
          naturalScrolling = true;
        };
      };
      updateDbusEnvironment = true;
      serverFlagsSection = ''
        Option "BlankTime" "180"
        Option "StandbyTime" "45"
        Option "SuspendTime" "45"
        Option "OffTime" "180"
      '';
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = false;
      };
    };
  };
}
