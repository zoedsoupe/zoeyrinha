{
  custom-config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = custom-config.direnv;
in {
  options.direnv.enable = mkEnableOption "Enables direnv";
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
