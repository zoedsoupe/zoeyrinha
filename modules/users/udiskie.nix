{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.udiskie;
in {
  options.zoedsoupe.udiskie = {
    enable = mkOption {
      description = "Enable Udiskie";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.udiskie= {
      inherit (cfg) enable;
      automount = true;
      notify = true;
    };
  };
}
