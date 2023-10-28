{
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.fzf;
in {
  options.fzf.enable = mkEnableOption "Enables FZF";
  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableFishIntegration = false;
      enableZshIntegration = true;
    };
  };
}
