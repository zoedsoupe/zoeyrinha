{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.clipmenu;
in {
  options.zoedsoupe.clipmenu = {
    enable = mkOption {
      description = "Enable Clipmenu";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.clipmenu = { inherit (cfg) enable; };
  };
}
