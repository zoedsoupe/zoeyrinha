{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.screen;
in
{
  options.zoedsoupe.screen.enable = mkOption {
    description = "Enable screen related services";
    type = types.bool;
    default = false;
  };

  config = mkIf (cfg.enable) {
    services = {
      redshift = {
        inherit (cfg) enable;
        brightness = {
          day = "1";
          night = "1";
        };
        temperature = {
          day = 5500;
          night = 3700;
        };
      };

      thermald = { inherit (cfg) enable; };
    };
  };
}
