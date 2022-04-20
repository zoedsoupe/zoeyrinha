{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.fzf;
in {
  options.zoedsoupe.fzf = {
    enable = mkOption {
      description = "Enable fzf";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.fzf = {
      inherit (cfg) enable;
      enableFishIntegration = config.zoedsoupe.fish.enable;
    };
  };
}
