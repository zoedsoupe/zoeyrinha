{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.clipmenu;
in {
  options.zoedsoupe.services = {
    enable = mkOption {
      description = "Enable Clipmenu";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    services.clipmenu.enable = { inherit (cfg) enable; };
  };
}
