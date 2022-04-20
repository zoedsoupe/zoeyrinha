{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.zram;
in {
  options.zoedsoupe.zram.enable = mkOption {
    description = "Enable Zram";
    type = types.bool;
    default = false;
  };

  config = mkIf (cfg.enable) {
    zramSwap = {
      inherit (cfg) enable;
      algorithm = "zstd";
      memoryPercent = 60;
    };
  };
}
