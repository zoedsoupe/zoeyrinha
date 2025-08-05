{
  lib,
  custom-config,
  bat-themes,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.bat;
in {
  options.bat.enable = mkEnableOption "Enables bat previewer";
  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        theme = "nyxvamp-veil";
      };
      themes = {
        nyxvamp-veil = {
          src = "${bat-themes}/themes";
          file = "nyxvamp-veil.tmTheme";
        };
      };
    };
  };
}
