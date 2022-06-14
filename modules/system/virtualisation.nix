{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.virtualisation;
in
{
  options.zoedsoupe.virtualisation.enable = mkOption {
    description = "Enable virtualisation";
    type = types.bool;
    default = false;
  };

  config = mkIf (cfg.enable) {
    virtualisation.docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
    virtualisation.libvirtd.enable = true;
    programs.dconf.enable = true;
  };
}
