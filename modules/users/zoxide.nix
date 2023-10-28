{
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.zoxide;
in {
  options.zoxide.enable = mkEnableOption "Enables zoxide";
  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
