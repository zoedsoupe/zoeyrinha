{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.direnv;
in
{
  options.zoedsoupe.direnv = {
    enable = mkOption {
      description = "Enable direnv";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
