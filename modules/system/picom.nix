{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.picom;
in
{
  options.zoedsoupe.picom.enable = mkOption {
    description = "Enable picom";
    type = types.bool;
    default = false;
  };

  config = mkIf (cfg.enable) {
    services.picom = {
      enable = true;
      inactiveOpacity = 0.8;
      backend = "glx";
      shadow = true;
      shadowOpacity = 0.5;
      shadowOffsets = [ (-60) (-25) ];
      shadowExclude = [
        "class_g = 'google-chrome-stable'"
      ];
      opacityRules = [
        "90:class_g = 'alacritty'"
      ];
      settings = {
        shadow = { radius = 5; };
        blur = {
          background = true;
          backgroundFrame = true;
          backgroundFixed = true;
          kern = "3x3box";
          strength = 10;
        };
      };
    };
  };
}
