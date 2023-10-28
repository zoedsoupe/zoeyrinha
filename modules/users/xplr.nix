{
  lib,
  custom-config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.xplr;
in {
  options.xplr = {
    enable = mkEnableOption "Enables TUI File Manager";
  };

  config = mkIf cfg.enable {
    programs.xplr = {
      enable = true;
    };
  };
}
