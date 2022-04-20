{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.zoedsoupe.security;
  lectureFile = builtins.toString ./modules/misc/groot.txt;
in {
  options.zoedsoupe.security.enable = mkOption {
    description = "Enable security modules";
    type = types.bool;
    default = false;
  };

  config = mkIf (cfg.enable) {
    security.apparmor.enable = true;
    security.polkit.enable = true;
    security.rtkit.enable = true;
    security.sudo = {
      enable = true;
      configFile = ''
        Defaults insults
        Defaults lecture=always
        Defaults lecture_file="${lectureFile}"
      '';
    };
  };
}
