{
  pkgs,
  unstable,
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.gh;
in {
  options.gh.enable = mkEnableOption "Enables github CLI (with extensions)";

  config = mkIf cfg.enable {
    programs.gh = {
      inherit (cfg) enable;
      package = unstable.gh;
      extensions = [pkgs.gh-dash];
      settings = {
        prompt = "enabled";
        git_protocol = "ssh";
        editor = "${pkgs.helix}/bin/hx";
      };
    };
  };
}
